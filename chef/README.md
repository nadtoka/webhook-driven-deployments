# Chef Test Kitchen over SSH

This blueprint keeps Chef Test Kitchen in the loop using the SSH driver. It expects an `.env` file in `chef/` to export SSH connection details and key paths; the file should be generated at runtime and never committed.

Example workflow:
```bash
cd chef
source .env
bundle install
kitchen converge 'core|db|load-balancer' -c
kitchen verify
```

Generate `.env` in two ways:
1. **Vault (optional)**: `ruby scripts/initenv_vault.rb` reads `VAULT_ADDR`, `VAULT_TOKEN`, and `VAULT_SECRET`, then writes `id_rsa` and `.env` in `chef/`.
2. **Terraform outputs**: `bash scripts/gen_env_from_terraform.sh` consumes Terraform JSON outputs (placeholder) to produce `.env` and an SSH key file when provided.

Suites (`core`, `db`, `load-balancer`) are placeholders; adapt to your cookbooks and topology.
