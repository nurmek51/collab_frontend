#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"
STACK="${1:-direct}"

if [[ "${STACK}" == "prod" ]]; then
	COMPOSE_FILE="${ROOT_DIR}/docker-compose.prod.yml"
else
	COMPOSE_FILE="${ROOT_DIR}/docker-compose.web.yml"
fi

cd "${ROOT_DIR}"
docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" ps
