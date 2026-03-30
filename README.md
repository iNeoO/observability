# Observability Stack

Stack locale basée sur Docker Compose pour lancer :

- Grafana
- Prometheus
- Loki

## Prérequis

- Docker
- Docker Compose v2

## Structure

- `docker-compose.yml` : orchestration complète
- `prometheus/` : configuration Prometheus
- `loki/` : configuration Loki
- `promtail/` : collecte des logs Docker vers Loki
- `grafana/provisioning/` : datasources Grafana préconfigurées

## Démarrage

1. Copier les variables d'environnement :

```bash
cp .env.example .env
```

2. Lancer la stack :

```bash
docker compose up -d
```

## Accès

- Grafana : http://localhost:5000
- Prometheus : http://localhost:5001
- Loki : http://localhost:5002

## Identifiants par défaut

- Grafana : `admin` / `admin`

## Notes

- `promtail` lit les logs Docker via `/var/run/docker.sock`, ce qui vise un hôte Linux.
