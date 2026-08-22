include .env

check-traefik:
ifeq (,$(shell docker ps -f name=^traefik$$ -q))
	$(error docker container traefik is not running)
endif

config/secrets/oidc/jwks/rsa.2048.key:
	@echo "Creating RSA key"
	mkdir -p config/secrets/oidc/jwks
	openssl genrsa -out config/secrets/oidc/jwks/rsa.2048.key 2048

# Dev-only OIDC client secrets. Never used in prod: on the prod server these
# files are created once by hand with the real hashes and are never
# regenerated, so this rule only ever fires for local dev setups.
DEV_OIDC_CLIENTS := paperless vikunja listmonk outline mitglieder aufnahme listig helios
DEV_OIDC_CLIENT_SECRET := insecure-dev-secret

config/secrets/oidc/clients/%:
	@echo "Creating dev OIDC client secret for $*"
	mkdir -p config/secrets/oidc/clients
	docker run --rm authelia/authelia authelia crypto hash generate pbkdf2 \
		--password '$(DEV_OIDC_CLIENT_SECRET)' --no-confirm \
		| sed -n 's/^Digest: //p' > $@

dev: check-traefik config/secrets/oidc/jwks/rsa.2048.key $(addprefix config/secrets/oidc/clients/,$(DEV_OIDC_CLIENTS))
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
