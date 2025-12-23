# Open Telekom Cloud core/db/load-balancer stack

This Terraform configuration provisions a minimal three-node topology on Open Telekom Cloud (OTC):

- Core node (application host)
- Database node
- Load balancer node

It creates a VPC, subnet, security group for SSH, optional floating IPs, and emits outputs that align with the repository's provider contract for Chef Test Kitchen.

## Prerequisites

- Terraform >= 1.3
- OTC credentials available in the environment per the [Open Telekom Cloud Terraform provider documentation](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs). Configure access key, secret, region, and project scope through environment variables supported by the provider.
- A valid `image_id` for your region (Ubuntu or another Linux image). Provide flavor IDs that exist in your project.

## Usage

```bash
cd terraform/providers/otc/core-lb-db
terraform init
terraform plan \
  -var "service=myservice" \
  -var "stage_name=pr123" \
  -var "image_id=<your_image_id>"
terraform apply

# Emit outputs for Chef/Kitchen consumption
terraform output -json
```

Key variables:
- `enable_floating_ip` (default: `true`) attaches floating IPs so CI can reach the nodes.
- `allowed_ssh_cidr` defaults to `0.0.0.0/0` for demo purposes. **Restrict this in real deployments.**
- `use_keypair_workaround` (default: `false`) lets you reuse an existing keypair/public key instead of creating one.
- `enable_dns` is `false` by default; DNS records require an existing zone ID and record name.

## Outputs consumed by Chef

- `ssh_host_core`, `ssh_host_db`, `ssh_host_lb` (publicly reachable hosts; fallback to private IP if floating IPs are disabled)
- `ssh_host` (legacy single-host output, points to the core host)
- `ssh_user`, `ssh_port`
- `ssh_private_key_pem` (sensitive; generated when `use_keypair_workaround` is false)
- `inventory` map for role-aware consumption

The helper script `chef/scripts/gen_env_from_terraform.sh` reads these outputs and writes `.env` for Test Kitchen.

## Notes

- No secrets or private keys are committed. Keys are generated at apply time and output only as sensitive values.
- Review cloud-init templates under `cloud-init/` and extend them with real bootstrap steps as needed.
- Destroy resources when finished to avoid unexpected costs.
