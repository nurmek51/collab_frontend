# Collab Frontend (Flutter Web) in Docker

By default this project now uses a **fast runtime-only Docker flow**.

- Web bundle is built by Flutter (`build/web`) with env from `.env`
- Docker builds only the nginx runtime image
- This is much faster and stable for server deploys

## One-command deploy (recommended)

```bash
bash scripts/web_deploy.sh
```

or with Makefile:

```bash
make deploy
```

What it does:
- `git pull --ff-only`
- Flutter web build from `.env` (fast mode)
- Docker build + `up -d --remove-orphans`
- health-check on `/health`
- auto rollback to previous image if health-check fails
- keeps only last 3 versioned images (current + 2 previous)

Useful options:

```bash
# keep current local commit (skip git pull)
bash scripts/web_deploy.sh --no-pull

# run full Dockerized build (Flutter build inside Docker)
bash scripts/web_deploy.sh --full

# prune dangling images after successful deploy
bash scripts/web_deploy.sh --prune
```

Helpers:

```bash
bash scripts/web_status.sh
bash scripts/web_logs.sh
bash scripts/web_rollback.sh 1   # rollback to previous version
bash scripts/web_rollback.sh 2   # rollback to version before previous
```

Makefile shortcuts:

```bash
make deploy
make deploy-no-pull
make rollback1
make rollback2
make status
make logs
```

## systemd (auto-start on reboot)

Linux only:

```bash
chmod +x scripts/install_systemd_service.sh
bash scripts/install_systemd_service.sh
```

Optional custom values:

```bash
# app dir, app user, app group
bash scripts/install_systemd_service.sh /opt/collab_frontend deploy deploy
```

Service control:

```bash
sudo systemctl status collab-web.service
sudo systemctl restart collab-web.service
sudo journalctl -u collab-web.service -f
```

Uninstall service:

```bash
chmod +x scripts/uninstall_systemd_service.sh
bash scripts/uninstall_systemd_service.sh
```

## 1) Prepare environment variables

```bash
cp .env.web.example .env
```

Edit `.env` and set your real values:

- `BASE_URL` — backend API URL
- `DEBUG` — `true` or `false`
- `FLUTTER_BUILD_MODE` — usually `release`
- `WEB_PORT` — host port (default `8080`)

## 2) Build web bundle (from `.env`)

```bash
bash scripts/build_web_from_env.sh
```

## 3) Build and run fast Docker image

```bash
docker compose -f docker-compose.web.yml --env-file .env build
docker compose -f docker-compose.web.yml --env-file .env up -d
```

Notes:

- This path does not download Flutter image inside Docker.
- Rebuild is usually very fast.

Open: `http://<server-ip>:${WEB_PORT}` (for default config: `http://<server-ip>:8080`)

## 4) Check status and logs

```bash
docker compose -f docker-compose.web.yml ps
docker compose -f docker-compose.web.yml logs -f collab-web
```

Health endpoint:

```bash
curl http://localhost:${WEB_PORT}/health
```

## 5) Stop

```bash
docker compose -f docker-compose.web.yml down
```

## Full Dockerized build (optional)

If you want Flutter build to run inside Docker instead of host machine:

```bash
DOCKER_BUILDKIT=1 docker compose -f docker-compose.web.full.yml --env-file .env build
docker compose -f docker-compose.web.full.yml --env-file .env up -d
```

First full build can be long because Flutter builder image is large.

## Optional cleanup (if you need to free disk space)

```bash
docker compose -f docker-compose.web.yml down --remove-orphans
docker image prune -f
docker builder prune -f
```
