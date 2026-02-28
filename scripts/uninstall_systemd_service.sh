#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "[ERROR] systemd uninstall is supported only on Linux"
  exit 1
fi

SERVICE_NAME="collab-web.service"
TARGET_FILE="/etc/systemd/system/${SERVICE_NAME}"

echo "[INFO] Stopping and disabling ${SERVICE_NAME}"
sudo systemctl stop ${SERVICE_NAME} 2>/dev/null || true
sudo systemctl disable ${SERVICE_NAME} 2>/dev/null || true

if [[ -f "${TARGET_FILE}" ]]; then
  echo "[INFO] Removing ${TARGET_FILE}"
  sudo rm -f "${TARGET_FILE}"
fi

sudo systemctl daemon-reload
sudo systemctl reset-failed || true

echo "[OK] ${SERVICE_NAME} removed"
