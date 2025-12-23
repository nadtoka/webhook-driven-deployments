# Variables

Both CI variants share the same variables. GitLab uses CI/CD variables; GitHub Actions uses workflow inputs or `repository_dispatch` payloads mapped to environment variables.

- `PHASE` — `APPLY` or `DESTROY` to control Terraform.
- `TF_VAR_service` — service identifier (used for environment naming).
- `TF_VAR_stage_name` — required stage name.
- `TF_VAR_stage` — optional suffix (e.g., `-blue`).
- `TF_VAR_dns` — optional DNS name for the environment.
- `MANIFEST_TAG` — optional manifest version identifier; included in `build.env` when present.
- `CALLBACK_URL_SUCCESS` / `CALLBACK_URL_FAIL` — optional URLs for callback notifications; treat as secrets.
- `VAULT_ADDR` / `VAULT_TOKEN` / `VAULT_SECRET` — optional; enables Vault-driven `.env` generation via `chef/scripts/initenv_vault.rb`.
- `VAULT_SSL_VERIFY` — set to `true` or `false` (default true) to control TLS verification when talking to Vault.
- `SSH_HOST` / `SSH_USER` / `SSH_PORT` / `SSH_KEY` — optional direct SSH connection values if skipping Vault.

Derived example naming: `ENV_NAME="${TF_VAR_service}-${TF_VAR_stage_name}${TF_VAR_stage}"`.
