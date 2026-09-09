#!/usr/bin/env bash
set -euo pipefail

service="${SONARQUBE_SERVICE:-sonarqube}"
container="${SONARQUBE_CONTAINER:-observability-sonarqube}"
tmp_container="observability-sonarqube-plugin-extract"
tmp_dir="$(mktemp -d)"
plugin_name="sonarqube-community-branch-plugin.jar"
plugin_path="/opt/sonarqube/extensions/plugins/${plugin_name}"

cleanup() {
  docker rm -f "${tmp_container}" >/dev/null 2>&1 || true
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

image="$(docker compose config | awk -v service="${service}:" '
  $1 == service { in_service = 1; next }
  in_service && $1 == "image:" { print $2; exit }
  in_service && $1 ~ /^[[:alnum:]_-]+:$/ { in_service = 0 }
')"

if [[ -z "${image}" ]]; then
  echo "Could not resolve image for service '${service}' from docker compose config." >&2
  exit 1
fi

echo "Syncing Community Branch Plugin from ${image}"
docker compose pull "${service}"

docker create --name "${tmp_container}" "${image}" >/dev/null
docker cp "${tmp_container}:${plugin_path}" "${tmp_dir}/${plugin_name}"

docker compose up -d --no-deps "${service}"

docker exec -u root "${container}" sh -eu -c '
  mkdir -p /opt/sonarqube/extensions/plugin-backups
  find /opt/sonarqube/extensions/plugins \
    -maxdepth 1 \
    -type f \
    -name "sonarqube-community-branch-plugin*.jar" \
    ! -name "sonarqube-community-branch-plugin.jar" \
    -exec mv {} /opt/sonarqube/extensions/plugin-backups/ \;
'
docker cp "${tmp_dir}/${plugin_name}" "${container}:${plugin_path}"
docker exec -u root "${container}" chown sonarqube:root "${plugin_path}"

docker compose restart "${service}"
docker compose ps "${service}"
