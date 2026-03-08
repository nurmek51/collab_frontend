SHELL := /bin/bash

.PHONY: deploy deploy-no-pull deploy-prod rollback1 rollback2 rollback1-prod rollback2-prod status status-prod logs logs-prod install-service uninstall-service

deploy:
	bash scripts/web_deploy.sh

deploy-no-pull:
	bash scripts/web_deploy.sh --no-pull

deploy-prod:
	bash scripts/web_deploy.sh --prod

rollback1:
	bash scripts/web_rollback.sh 1 direct

rollback2:
	bash scripts/web_rollback.sh 2 direct

rollback1-prod:
	bash scripts/web_rollback.sh 1 prod

rollback2-prod:
	bash scripts/web_rollback.sh 2 prod

status:
	bash scripts/web_status.sh direct

status-prod:
	bash scripts/web_status.sh prod

logs:
	bash scripts/web_logs.sh direct

logs-prod:
	bash scripts/web_logs.sh prod

install-service:
	bash scripts/install_systemd_service.sh

uninstall-service:
	bash scripts/uninstall_systemd_service.sh
