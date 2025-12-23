# Webhook-driven deployments

This repository is a public-safe blueprint for building webhook-driven ephemeral environments. A webhook payload kicks off CI, optionally parses a manifest for component tags, applies Terraform (placeholder here), runs Chef Test Kitchen over SSH, sends a callback, then destroys the environment. Two CI flavors are included:

- **GitLab CI template** (`gitlab/terraform-chef-ephemeral-env.yml`) — reference implementation.
- **GitHub Actions workflow** (`github-actions/terraform-ephemeral-env.yml`) — mirrors the GitLab flow. GitHub Actions variant not validated in all real environments; may require minor adjustments depending on cloud auth and Kitchen driver.

## Quickstart

### GitLab (reference)
1. Copy `gitlab/terraform-chef-ephemeral-env.yml` into your project or include it as a template.
2. Set CI/CD variables (examples):
   - `PHASE=APPLY` or `PHASE=DESTROY`
   - `TF_VAR_service`, `TF_VAR_stage_name`, optional `TF_VAR_stage`, `TF_VAR_dns`
   - Optional: `MANIFEST_TAG`, `CALLBACK_URL_SUCCESS`, `CALLBACK_URL_FAIL`, Vault variables if using `chef/scripts/initenv_vault.rb`.
3. Run the pipeline; it will parse the manifest (if present), run Terraform in `terraform/environments/example`, generate Chef `.env`, and call Kitchen.

### GitHub Actions
1. Use `github-actions/terraform-ephemeral-env.yml` in your repository.
2. Trigger with **workflow_dispatch** inputs or **repository_dispatch** (`deploy` event) carrying the same keys as the GitLab variables.
3. The workflow repeats the same flow: parse manifest, Terraform apply/destroy, generate Chef `.env`, Kitchen converge/verify, send callback.

### Webhook trigger example
- A webhook listener can translate the payload into a GitHub `repository_dispatch` event or start a GitLab pipeline. This repository does not ship a webhook server; use placeholders such as `example.com` and treat webhook URLs as secrets.

## Documentation
- [Flow overview](docs/flow.md)
- [Variables](docs/variables.md)
- [Security guidance](docs/security.md)
- [Provider outputs contract](docs/provider-contract.md)

## Notes
- Terraform configuration under `terraform/environments/example` is a placeholder using `null_resource` and dummy outputs to stay runnable without cloud credentials.
- A real Open Telekom Cloud stack lives at `terraform/providers/otc/core-lb-db`. Point `TF_ROOT` at this path (for example in CI) to provision a core/db/load-balancer trio that emits the expected Kitchen outputs.
- Chef Test Kitchen is configured for SSH and expects credentials via environment (.env). Vault and Terraform helper scripts generate these files at runtime without committing secrets.
- Rotate any leaked tokens, webhook URLs, or keys immediately. Never commit secrets to this repository.
