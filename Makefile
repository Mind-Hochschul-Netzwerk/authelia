include .env

check-traefik:
ifeq (,$(shell docker ps -f name=^traefik$$ -q))
	$(error docker container traefik is not running)
endif

config/secrets/oidc/jwks/rsa.2048.key:
	@echo "Creating RSA key"
	mkdir -p config/secrets/oidc/jwks
	openssl genrsa -out config/secrets/oidc/jwks/rsa.2048.key 2048

dev: check-traefik config/secrets/oidc/jwks/rsa.2048.key
	@echo "Starting DEV Server"
	docker compose up -d --force-recreate --remove-orphans

prod: check-traefik
	@echo "Starting Production Server"
	docker compose up -d --pull always --force-recreate --remove-orphans

upgrade:
	docker compose stop
	sudo chown -R deployer:deployer config/
	git pull
	make prod

shell:
	docker compose exec app sh

rootshell:
	docker compose exec --user root app sh

logs:
	docker compose logs -f
