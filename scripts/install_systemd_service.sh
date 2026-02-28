#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "[ERROR] systemd install is supported only on Linux"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_FILE="${ROOT_DIR}/deploy/systemd/collab-web.service"
SERVICE_NAME="collab-web.service"
TARGET_FILE="/etc/systemd/system/${SERVICE_NAME}"

APP_DIR="${1:-${ROOT_DIR}}"
APP_USER="${2:-${SUDO_USER:-$(id -un)}}"
APP_GROUP="${3:-$(id -gn "${APP_USER}")}" 

if [[ ! -f "${TEMPLATE_FILE}" ]]; then
  echo "[ERROR] Template not found: ${TEMPLATE_FILE}"
  exit 1
fi

if [[ ! -f "${APP_DIR}/.env" ]]; then
  echo "[ERROR] .env not found in ${APP_DIR}. Create it before enabling service."
  exit 1
fi

TMP_FILE="$(mktemp)"
trap 'rm -f "${TMP_FILE}"' EXIT

sed \
  -e "s#__APP_DIR__#${APP_DIR}#g" \
  -e "s#__APP_USER__#${APP_USER}#g" \
  -e "s#__APP_GROUP__#${APP_GROUP}#g" \
  "${TEMPLATE_FILE}" > "${TMP_FILE}"

echo "[INFO] Installing ${SERVICE_NAME}"
sudo cp "${TMP_FILE}" "${TARGET_FILE}"
sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_NAME}
sudo systemctl restart ${SERVICE_NAME}

sleep 2
sudo systemctl --no-pager --full status ${SERVICE_NAME} || true

echo "[OK] systemd service installed and started"
