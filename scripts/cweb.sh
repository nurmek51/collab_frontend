#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMAND="${1:-help}"

cd "${ROOT_DIR}"

case "${COMMAND}" in
  deploy)
    bash scripts/web_deploy.sh
    ;;
  deploy-prod)
    bash scripts/web_deploy.sh --prod
    ;;
  deploy-no-pull)
    bash scripts/web_deploy.sh --no-pull
    ;;
  status)
    bash scripts/web_status.sh direct
    ;;
  status-prod)
    bash scripts/web_status.sh prod
    ;;
  logs)
    bash scripts/web_logs.sh direct
    ;;
  logs-prod)
    bash scripts/web_logs.sh prod
    ;;
  rollback)
    bash scripts/web_rollback.sh "${2:-1}" direct
    ;;
  rollback-prod)
    bash scripts/web_rollback.sh "${2:-1}" prod
    ;;
  build)
    bash scripts/build_web_from_env.sh
    ;;
  help|--help|-h)
    cat <<'EOF'
Usage:
  bash scripts/cweb.sh deploy
  bash scripts/cweb.sh deploy-prod
  bash scripts/cweb.sh deploy-no-pull
  bash scripts/cweb.sh status
  bash scripts/cweb.sh status-prod
  bash scripts/cweb.sh logs
  bash scripts/cweb.sh logs-prod
  bash scripts/cweb.sh rollback [1|2]
  bash scripts/cweb.sh rollback-prod [1|2]
  bash scripts/cweb.sh build
EOF
    ;;
  *)
    echo "[ERROR] Unknown command: ${COMMAND}"
    exit 1
    ;;
esac