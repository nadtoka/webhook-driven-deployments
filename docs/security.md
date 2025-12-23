# Security guidance

- Never commit secrets, SSH keys, webhook URLs, or tokens. Use CI variables or GitHub Secrets instead.
- Treat webhook URLs and callback URLs as secrets; rotate them immediately if leaked.
- `chef/scripts/initenv_vault.rb` expects Vault variables; prefer TLS verification. `VAULT_SSL_VERIFY=false` is available only when absolutely required.
- If a script writes SSH keys, it writes them to `.gitignored` paths (`chef/id_rsa`) at runtime; never store private keys in Git.
- If you suspect a leak, rotate credentials and webhook tokens quickly, then re-run the pipeline.
