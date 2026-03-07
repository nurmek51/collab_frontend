#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FAST="${ROOT_DIR}/docker-compose.web.yml"
COMPOSE_FULL="${ROOT_DIR}/docker-compose.web.full.yml"
ENV_FILE="${ROOT_DIR}/.env"

MODE="fast"
DO_PULL="true"
PRUNE="false"
KEEP_VERSIONS="3"

for arg in "$@"; do
  case "$arg" in
    --no-pull)
      DO_PULL="false"
      ;;
    --full)
      MODE="full"
      ;;
    --prune)
      PRUNE="true"
      ;;
    *)
      echo "[ERROR] Unknown argument: $arg"
      echo "Usage: bash scripts/web_deploy.sh [--no-pull] [--full] [--prune]"
      exit 1
      ;;
  esac
done

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "[ERROR] .env not found. Run: cp .env.web.example .env"
  exit 1
fi

if [[ "${MODE}" == "full" ]]; then
  COMPOSE_FILE="${ROOT_DIR}/docker-compose.prod.yml"
  IMAGE_PREFIX="collab-web"
else
  COMPOSE_FILE="${COMPOSE_FAST}"
  IMAGE_PREFIX="collab-web:runtime"
fi

TAG="$(date +%Y%m%d%H%M%S)"
WEB_IMAGE="${IMAGE_PREFIX}-${TAG}"
export WEB_IMAGE

cd "${ROOT_DIR}"

if [[ "${DO_PULL}" == "true" ]]; then
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "[INFO] Pulling latest changes from remote..."
    git pull --ff-only
  else
    echo "[WARN] Not a git repository, skipping pull"
  fi
fi

if [[ "${MODE}" == "fast" ]]; then
  echo "[INFO] Building Flutter web artifacts from .env"
  bash scripts/build_web_from_env.sh
fi

echo "[INFO] Building Docker image using $(basename "${COMPOSE_FILE}")"
# Use DOCKER_BUILDKIT and explicit build-arg for cache
export DOCKER_BUILDKIT=1
docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" build --build-arg BUILDKIT_INLINE_CACHE=1
# Optional: tag for better caching if using registry, but locally Docker Kit handles it
# docker tag "${WEB_IMAGE}" "${IMAGE_PREFIX}"

echo "[INFO] Starting updated container"
docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" up -d --remove-orphans --no-build

WEB_PORT="$(grep -E '^WEB_PORT=' "${ENV_FILE}" | tail -n 1 | cut -d'=' -f2- || true)"
WEB_PORT="${WEB_PORT:-8080}"
HEALTH_URL="http://localhost:${WEB_PORT}/health"

echo "[INFO] Waiting for health endpoint: ${HEALTH_URL}"
for i in {1..30}; do
  if curl -fsS "${HEALTH_URL}" >/dev/null 2>&1; then
    echo "[OK] Deploy completed. Service is healthy."

    versioned_images=()
    while IFS= read -r line; do
      versioned_images+=("$line")
    done < <(docker image ls --format '{{.Repository}}:{{.Tag}}' | grep "^${IMAGE_PREFIX}-" || true)
    if (( ${#versioned_images[@]} > KEEP_VERSIONS )); then
      for old_image in "${versioned_images[@]:KEEP_VERSIONS}"; do
        docker image rm "${old_image}" >/dev/null 2>&1 || true
      done
    fi

    docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" ps
    if [[ "${PRUNE}" == "true" ]]; then
      echo "[INFO] Pruning dangling images"
      docker image prune -f >/dev/null
    fi
    exit 0
  fi
  sleep 2
done

echo "[ERROR] Health check failed after deploy"
docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" logs --tail 80 collab-web || true

echo "[WARN] Attempting automatic rollback to previous image"
if bash "${ROOT_DIR}/scripts/web_rollback.sh" 1 "${MODE}"; then
  echo "[OK] Rollback succeeded"
else
  echo "[ERROR] Rollback failed"
fi

exit 1
