# Terraform placeholder

This environment is a placeholder that keeps Terraform in the flow without requiring cloud credentials. Replace it with real modules (for example, an Open Telekom Cloud stack for three VMs: core, db, load balancer) when ready.

Usage:
```bash
cd terraform/environments/example
terraform init
terraform plan
```

Outputs provide dummy SSH connection data for Chef scripts. `gen_env_from_terraform.sh` consumes them to build a `.env` file. TODO: swap the null resources with real infrastructure.
