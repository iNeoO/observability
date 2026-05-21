# Observability Stack

This repository provides a local observability stack based on Docker Compose for monitoring self-hosted services with:

- Grafana
- Prometheus
- Loki
- Promtail

It includes pre-provisioned Grafana datasources and dashboards for the services currently monitored from `tuturu.io`.

## Monitored Applications

- [https://tuturu.io](https://tuturu.io) - [iNeoO/home](https://github.com/iNeoO/home)
- [https://ocr.tuturu.io](https://ocr.tuturu.io) - [iNeoO/ocr](https://github.com/iNeoO/ocr)
- [https://urlshortener.tuturu.io](https://urlshortener.tuturu.io) - [iNeoO/urlshortener](https://github.com/iNeoO/urlshortener)
- [https://manga-reader.tuturu.io](https://manga-reader.tuturu.io) - [iNeoO/manga-reader](https://github.com/iNeoO/manga-reader)

## What Is Included

- `docker-compose.yml`: runs Grafana, Prometheus, Loki, and Promtail
- `prometheus/prometheus.yml`: scrape configuration for infrastructure and application metrics
- `loki/config.yml`: Loki storage and ingestion configuration
- `promtail/config.yml`: Docker and PM2 log collection configuration
- `grafana/provisioning/`: automatically provisions datasources and dashboards
- `grafana/dashboards/`: ready-to-use dashboards for infrastructure and applications

## Available Dashboards

- `Arch Server Overview`
- `Tuturu Application Overview`
- `HTTP URL Shortener Overview`
- `OCR Observability`
- `Manga Reader Backend`

## Metrics Targets

Prometheus is configured to scrape:

- The observability stack itself: Prometheus, Grafana, and Loki
- Host-level metrics from Node Exporter on `host.docker.internal:9100`
- PM2 metrics on `host.docker.internal:9209`
- RabbitMQ metrics for:
  - `urlshortener` on `host.docker.internal:15692`
  - `ocr` on `host.docker.internal:15693`
- Application metrics for:
  - `urlshortener` backend on `host.docker.internal:4000`
  - `urlshortener` redirector on `host.docker.internal:4001`
  - `ocr` backend on `host.docker.internal:4010`
  - `ocr` frontend on `host.docker.internal:3010`
  - `manga-reader` on `host.docker.internal:4020`

## Logs Collection

Promtail collects:

- Docker container logs through the Docker socket
- PM2 log files from `${PM2_LOGS_PATH}`

PM2 logs are labeled by application name and stream (`out` or `error`) before being shipped to Loki.

## Prerequisites

- Docker
- Docker Compose v2
- A running Node Exporter on the host if you want host dashboards to work
- A running PM2 metrics exporter on the host if you want PM2 dashboards to work
- The monitored applications exposing Prometheus-compatible `/metrics` endpoints

## Getting Started

1. Copy the environment file:

```bash
cp .env.example .env
```

2. Adjust the values in `.env`, especially:

```bash
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=admin
GRAFANA_DOMAIN=grafana.example.com
GRAFANA_ROOT_URL=https://grafana.example.com
PM2_LOGS_PATH=/home/user/.pm2/logs
```

3. Start the stack:

```bash
docker compose up -d
```

## Access

- Grafana: `http://localhost:5000`
- Prometheus: `http://localhost:5001`
- Loki: `http://localhost:5002`

## Reverse Proxy

To expose Grafana behind a reverse proxy, set the following values in `.env`:

```bash
GRAFANA_DOMAIN=grafana.example.com
GRAFANA_ROOT_URL=https://grafana.example.com
```

Then proxy requests to `http://127.0.0.1:5000`.

## Default Credentials

- Grafana: `admin` / `admin`
