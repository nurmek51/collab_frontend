SHELL := /bin/bash

.PHONY: deploy deploy-no-pull deploy-full rollback1 rollback2 status logs install-service uninstall-service

deploy:
	bash scripts/web_deploy.sh

deploy-no-pull:
	bash scripts/web_deploy.sh --no-pull

deploy-full:
	bash scripts/web_deploy.sh --full

rollback1:
	bash scripts/web_rollback.sh 1 fast

rollback2:
	bash scripts/web_rollback.sh 2 fast

status:
	bash scripts/web_status.sh

logs:
	bash scripts/web_logs.sh

install-service:
	bash scripts/install_systemd_service.sh

uninstall-service:
	bash scripts/uninstall_systemd_service.sh
