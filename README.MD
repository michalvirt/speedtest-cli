# ⚡ Speedtest Collector Container

A lightweight, secure container image that periodically runs the official [Ookla Speedtest CLI](https://www.speedtest.net/apps/cli) binary and saves output files in structured JSON format for visualization in the **Speedtest Dashboard**.

---

## 📋 Features

- **Official Ookla Binary**: Uses the native Linux `ookla-speedtest` binary for accurate multi-stream gigabit bandwidth and latency testing.
- **Configurable Interval Loop**: Schedules tests every `N` seconds (default: 600s / 10 minutes) without relying on heavy cron daemons.
- **Unprivileged Non-Root Execution**: Runs as a dedicated `speedtestuser` (UID 1000) for security.
- **Structured JSON Output**: Automatically exports full test results to `/usr/local/speedtest-data/<hostname>_<YYYYMMDD_HHMMSS>.json`.
- **Zero Overhead**: Minimal `debian:trixie-slim` runtime containing only `tzdata` and `ca-certificates`.

---

## 🛠️ Prerequisites

- [Docker](https://www.docker.com/) or [Podman](https://podman.io/) installed.

---

## 🔨 Building the Image

From the `speedtest-cli` directory:

```bash
# Using Podman
podman build -t speedtest-cli -f Containerfile .

# Using Docker
docker build -t speedtest-cli -f Containerfile .
```

---

## 🚀 Running the Container

### Standalone (Docker)

```bash
docker run -d \
  --name speedtest-cli \
  --hostname speedtest-cli \
  -v speedtest-data:/usr/local/speedtest-data \
  -e SPEEDTEST_INTERVAL="600" \
  -e TZ="Europe/Prague" \
  --restart unless-stopped \
  speedtest-cli
```

### Standalone (Podman)

On SELinux systems (e.g. Fedora, RHEL), use `:Z` to grant appropriate container write permissions:

```bash
podman run -d \
  --name speedtest-cli \
  --hostname speedtest-cli \
  -v speedtest-data:/usr/local/speedtest-data:Z \
  -e SPEEDTEST_INTERVAL="600" \
  -e TZ="Europe/Prague" \
  localhost/speedtest-cli
```

---

## ⚙️ Environment Variables

| Variable | Default | Description |
| :--- | :--- | :--- |
| `SPEEDTEST_INTERVAL` | `600` | Interval between speedtests in seconds (e.g. `300` for 5 min, `600` for 10 min, `3600` for 1 hour). |
| `TZ` | `Europe/Prague` | Timezone identifier for timestamps and logs. |
| `SPEEDTEST_ARGS` | *(empty)* | Additional CLI arguments passed to `speedtest` (e.g. `--server <id>`). |

---

## 📝 Checking Logs

To follow test runs in real time:

```bash
# Docker
docker logs -f speedtest-cli

# Podman
podman logs -f speedtest-cli
```

Example log output:
```text
Active Timezone: Europe/Prague
Current Time: Mon Sep 28 11:15:00 CEST 2026
Starting Speedtest loop every 600 seconds...
Running speedtest at Mon Sep 28 11:15:00 CEST 2026...
Results successfully saved to /usr/local/speedtest-data/speedtest-cli_20260928_111502.json
Waiting 600 seconds...
```

---

## 🤝 Integration with Speedtest Dashboard

When paired with `speedtest-dashboard`, both containers share the `speedtest-data` volume:

- `speedtest-cli` writes `.json` files to `/usr/local/speedtest-data`.
- `speedtest-dashboard` reads `.json` files from `/app/data` (read-only).

See the [top-level `docker-compose.yml`](../docker-compose.yml) to launch both services simultaneously.
