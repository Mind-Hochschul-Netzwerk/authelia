# Authelia Deployment

## add a new client

edit `config/configuration.yml` and reference the client secret via
`client_secret: '{{ secret "/config/secrets/oidc/clients/<client_id>" }}'`
(see [client secrets](#client-secrets) below). Also add `<client_id>` to
`DEV_OIDC_CLIENTS` in the `Makefile` so a dev secret gets generated
automatically.

## client secrets

`client_secret` values are never stored in `configuration.yml` itself, only
referenced via `{{ secret "/config/secrets/oidc/clients/<client_id>" }}`.

- **dev**: `make dev` generates these files automatically with the
  well-known, safe-to-publish plaintext secret `insecure-dev-secret` (see
  `DEV_OIDC_CLIENT_SECRET` in the `Makefile`). Use that value when configuring
  OIDC in the client apps locally.
- **prod**: create the file once by hand on the server with the real hash,
  e.g. `docker run --rm authelia/authelia authelia crypto hash generate
  pbkdf2 --password 'the-real-secret'` and save the printed digest (without
  the `Digest: ` prefix) to `config/secrets/oidc/clients/<client_id>`.

see
[How do I generate a client identifier or client secret?](https://www.authelia.com/integration/openid-connect/frequently-asked-questions/#how-do-i-generate-a-client-identifier-or-client-secret)

