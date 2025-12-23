# Flow

The blueprint models an ephemeral environment lifecycle: webhook → CI → Terraform → Chef → callback → destroy. Terraform and Chef are placeholders that you can extend to real infrastructure.

## Steps
1. **Input**: CI variables or webhook payload provide service, stage, and optional manifest tag.
2. **Manifest parse**: `scripts/manifest/parse_manifest.sh` optionally extracts component tags from an XML manifest and writes `build.env`.
3. **Terraform apply**: `terraform/environments/example` demonstrates a no-cloud `null_resource` plan. In a real setup, replace it with cloud modules.
4. **Chef Test Kitchen**: `chef/kitchen.yml` uses the SSH driver to converge and verify suites (`core`, `db`, `load-balancer`) against hosts provided via `.env`.
5. **Callback**: `scripts/callbacks/callback.sh` posts status to optional callback URLs without breaking the pipeline if unreachable.
6. **Destroy**: Run Terraform destroy (no-op with the placeholder) to keep ephemeral lifecycle consistent.

## Diagram
```mermaid
flowchart TD
    A[Webhook / Manual trigger] --> B[CI pipeline]
    B --> C[Parse manifest (optional)]
    C --> D[Terraform apply (placeholder)]
    D --> E[Chef Kitchen converge/verify over SSH]
    E --> F[Callback notify]
    F --> G[Terraform destroy]
```
