# Terraform placeholder

This environment is a placeholder that keeps Terraform in the flow without requiring cloud credentials. A real Open Telekom Cloud stack for three VMs (core, db, load balancer) is available under `terraform/providers/otc/core-lb-db`.

Usage:
```bash
cd terraform/environments/example
terraform init
terraform plan
```

Outputs provide dummy SSH connection data for Chef scripts. `gen_env_from_terraform.sh` consumes them to build a `.env` file. Point `TF_ROOT` at the OTC folder to use the real provider when credentials are available.
