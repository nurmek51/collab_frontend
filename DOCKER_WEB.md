# Collab Frontend Docker Deploy

This project now uses only the fast deploy flow:

- Flutter builds `build/web` on the host
- Docker packages only the nginx runtime image
- No Flutter compilation happens inside Docker

## Deploy modes

### Direct mode

Use this when you want the app served directly on `WEB_PORT`.

```bash
bash scripts/web_deploy.sh
```

or:

```bash
make deploy
```

### Prod mode

Use this when you run the full stack with `nginx-proxy`, domain, and SSL.

```bash
bash scripts/web_deploy.sh --prod
```

or:

```bash
make deploy-prod
```

## What deploy does

- `git pull --ff-only`
- host-side `flutter build web`
- very fast runtime Docker build
- `docker compose up -d --remove-orphans`
- health check
- rollback on failure

## Useful commands

```bash
# direct mode
make deploy
make deploy-no-pull
make rollback1
make rollback2
make status
make logs

# prod mode
make deploy-prod
make rollback1-prod
make rollback2-prod
make status-prod
make logs-prod
```

## Easy alias / wrapper

Use the helper script:

```bash
bash scripts/cweb.sh help
```

Recommended alias on the server:

```bash
echo "alias cweb='cd /opt/collab_frontend && bash scripts/cweb.sh'" >> ~/.bashrc
source ~/.bashrc
```

Then use:

```bash
cweb deploy
cweb deploy-prod
cweb status
cweb logs
cweb rollback 1
cweb rollback-prod 1
```

## Server setup

```bash
git clone <your-repo-url> /opt/collab_frontend
cd /opt/collab_frontend
cp .env.web.example .env
```

Edit `.env` and set:

- `BASE_URL`
- `DEBUG`
- `FLUTTER_BUILD_MODE=release`
- `WEB_PORT` for direct mode

If Flutter is not installed on the server, install it once and make sure `flutter` is in `PATH`.

Then run either:

```bash
bash scripts/web_deploy.sh
```

or:

```bash
bash scripts/web_deploy.sh --prod
```

## systemd

Linux only:

```bash
chmod +x scripts/install_systemd_service.sh
bash scripts/install_systemd_service.sh
```

## Cleanup

```bash
docker image prune -f
docker builder prune -f
```
