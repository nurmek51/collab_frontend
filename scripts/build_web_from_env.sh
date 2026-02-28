#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "[ERROR] .env file not found. Copy .env.web.example to .env first."
  exit 1
fi

set -a
source "${ENV_FILE}"
set +a

DEBUG="${DEBUG:-false}"
BASE_URL="${BASE_URL:-https://collab-api-810993564533.europe-north2.run.app/}"
FLUTTER_BUILD_MODE="${FLUTTER_BUILD_MODE:-release}"

echo "[INFO] Building Flutter web with env from .env"
echo "[INFO] DEBUG=${DEBUG}"
echo "[INFO] BASE_URL=${BASE_URL}"
echo "[INFO] FLUTTER_BUILD_MODE=${FLUTTER_BUILD_MODE}"

cd "${ROOT_DIR}"
flutter pub get
flutter build web --"${FLUTTER_BUILD_MODE}" \
  --dart-define=DEBUG="${DEBUG}" \
  --dart-define=BASE_URL="${BASE_URL}"

echo "[INFO] build/web is ready"
