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
PACKAGE_CONFIG="${ROOT_DIR}/.dart_tool/package_config.json"

# Move pub get inside the check and try to run it safely. 
# Permission denied on pubspec.lock often happens if it's owned by root from previous Docker runs.
if [[ ! -f "${PACKAGE_CONFIG}" || "${ROOT_DIR}/pubspec.yaml" -nt "${PACKAGE_CONFIG}" || "${ROOT_DIR}/pubspec.lock" -nt "${PACKAGE_CONFIG}" ]]; then
  echo "[INFO] Running flutter pub get (dependencies changed)"
  # Try to fix permissions if we are on Linux and have sudo, otherwise just run it
  if [[ "$(uname -s)" == "Linux" ]]; then
    sudo chown -R "$(id -u):$(id -g)" "${ROOT_DIR}/pubspec.lock" 2>/dev/null || true
    sudo chown -R "$(id -u):$(id -g)" "${ROOT_DIR}/.dart_tool" 2>/dev/null || true
  fi
  flutter pub get || { echo "[ERROR] flutter pub get failed. Try running 'sudo chown -R $(whoami) .' on the server."; exit 1; }
else
  echo "[INFO] Skipping flutter pub get (dependencies unchanged)"
fi

# Optimized for server build speed:
# --no-wasm-dry-run: Skip the slow WASM compatibility check that failed in your logs
# --no-tree-shake-icons: Speeds up compilation by skipping the icon analysis step
# --no-source-maps: Reduces memory usage and build time by not generating mapping files
flutter build web --"${FLUTTER_BUILD_MODE}" \
  --no-pub \
  --no-wasm-dry-run \
  --no-tree-shake-icons \
  --no-source-maps \
  --dart-define=DEBUG="${DEBUG}" \
  --dart-define=BASE_URL="${BASE_URL}"

echo "[INFO] build/web is ready"
