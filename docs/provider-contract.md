# Provider outputs contract

This blueprint expects Terraform providers to emit a minimal set of outputs so Chef Test Kitchen can connect over SSH. Providers should stay public-safe and avoid embedding any real secrets.

## Required outputs

| Output key | Purpose |
| --- | --- |
| `ssh_host` | Hostname or IP address reachable from the CI runner (legacy single-host). |
| `ssh_user` | SSH user for Test Kitchen. |
| `ssh_port` | SSH port (default 22). |

## Optional outputs

| Output key | Purpose |
| --- | --- |
| `ssh_private_key` or `ssh_private_key_pem` | Inline private key PEM. The helper writes this to `chef/id_rsa` with `chmod 600`. |
| `ssh_key_path` | Path to a key already present on disk for the runner. |
| `core_ip`, `db_ip`, `lb_ip` | Helpful hints for debugging multi-node topologies. |
| `inventory` | A map of role => host data when available. |
| `ssh_host_core`, `ssh_host_db`, `ssh_host_lb` | Role-specific hosts for multi-node environments. |

## Consumption by scripts

`chef/scripts/gen_env_from_terraform.sh` reads the outputs above and writes a `.env` file consumed by Test Kitchen. The script prefers `ssh_host_core` (fallback to `ssh_host`) and still requires `ssh_user` and `ssh_port`; missing values cause it to exit with an error.

## Provider roadmap

Providers are added incrementally. The first target is **Open Telekom Cloud (OTC)**, followed by **AWS**, **GCP**, and **Azure**. Align outputs with the table above to keep Chef integration stable across providers.
