#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"
STEP_BACK="${1:-1}"
MODE="${2:-fast}"

if [[ ! "${STEP_BACK}" =~ ^[12]$ ]]; then
  echo "[ERROR] STEP_BACK must be 1 or 2"
  echo "Usage: bash scripts/web_rollback.sh [1|2] [fast|full]"
  exit 1
fi

if [[ "${MODE}" == "fast" ]]; then
  COMPOSE_FILE="${ROOT_DIR}/docker-compose.web.yml"
  IMAGE_PREFIX="collab-web:runtime"
else
  COMPOSE_FILE="${ROOT_DIR}/docker-compose.web.full.yml"
  IMAGE_PREFIX="collab-web:full"
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "[ERROR] .env not found"
  exit 1
fi

cd "${ROOT_DIR}"

versioned_images=()
while IFS= read -r line; do
  versioned_images+=("$line")
done < <(docker image ls --format '{{.Repository}}:{{.Tag}}' | grep "^${IMAGE_PREFIX}-" || true)

if (( ${#versioned_images[@]} < STEP_BACK + 1 )); then
  echo "[ERROR] Not enough versions for rollback by ${STEP_BACK} step(s)."
  echo "[INFO] Found versions: ${#versioned_images[@]}"
  exit 1
fi

TARGET_IMAGE="${versioned_images[STEP_BACK]}"
export WEB_IMAGE="${TARGET_IMAGE}"

echo "[INFO] Rolling back to ${WEB_IMAGE}"
docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" up -d --remove-orphans --no-build

WEB_PORT="$(grep -E '^WEB_PORT=' "${ENV_FILE}" | tail -n 1 | cut -d'=' -f2- || true)"
WEB_PORT="${WEB_PORT:-8080}"
HEALTH_URL="http://localhost:${WEB_PORT}/health"

for i in {1..20}; do
  if curl -fsS "${HEALTH_URL}" >/dev/null 2>&1; then
    echo "[OK] Rollback completed and service is healthy"
    docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" ps
    exit 0
  fi
  sleep 2
done

echo "[ERROR] Rollback image did not pass health-check"
docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" logs --tail 80 collab-web || true
exit 1
