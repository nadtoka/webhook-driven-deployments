#!/usr/bin/env bash
set -euo pipefail

TF_DIR=${1:-"$(cd "$(dirname "${BASH_SOURCE[0]}")/../../terraform/environments/example" && pwd)"}

if ! command -v terraform >/dev/null 2>&1; then
  echo "Terraform is required on PATH to generate outputs." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required to parse terraform outputs." >&2
  exit 1
fi

OUTPUT_JSON=$(terraform -chdir="$TF_DIR" output -json)

SSH_HOST_CORE=$(echo "$OUTPUT_JSON" | jq -er '.ssh_host_core.value // empty' || true)
SSH_HOST_DB=$(echo "$OUTPUT_JSON" | jq -er '.ssh_host_db.value // empty' || true)
SSH_HOST_LB=$(echo "$OUTPUT_JSON" | jq -er '.ssh_host_lb.value // empty' || true)
SSH_HOST_SINGLE=$(echo "$OUTPUT_JSON" | jq -er '.ssh_host.value // empty' || true)
SSH_USER=$(echo "$OUTPUT_JSON" | jq -er '.ssh_user.value // empty' || true)
SSH_PORT=$(echo "$OUTPUT_JSON" | jq -er '.ssh_port.value // empty' || true)
SSH_KEY_CONTENT=$(echo "$OUTPUT_JSON" | jq -er '.ssh_private_key.value // empty' || true)
SSH_KEY_CONTENT_PEM=$(echo "$OUTPUT_JSON" | jq -er '.ssh_private_key_pem.value // empty' || true)
SSH_KEY_PATH_OUTPUT=$(echo "$OUTPUT_JSON" | jq -er '.ssh_key_path.value // empty' || true)

if [[ -z "$SSH_HOST_CORE" ]]; then
  SSH_HOST_CORE="$SSH_HOST_SINGLE"
fi

if [[ -z "$SSH_HOST_CORE" || -z "$SSH_USER" || -z "$SSH_PORT" ]]; then
  echo "Missing required outputs: ssh_host_core=${SSH_HOST_CORE:-unset} ssh_user=${SSH_USER:-unset} ssh_port=${SSH_PORT:-unset}" >&2
  exit 1
fi

if [[ -z "$SSH_HOST_DB" ]]; then
  SSH_HOST_DB="$SSH_HOST_SINGLE"
fi

if [[ -z "$SSH_HOST_LB" ]]; then
  SSH_HOST_LB="$SSH_HOST_SINGLE"
fi

CHEF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$CHEF_DIR/.env"
KEY_FILE="$CHEF_DIR/id_rsa"

if [[ -n "$SSH_KEY_PATH_OUTPUT" ]]; then
  KEY_FILE="$SSH_KEY_PATH_OUTPUT"
elif [[ -n "$SSH_KEY_CONTENT" || -n "$SSH_KEY_CONTENT_PEM" ]]; then
  KEY_MATERIAL="${SSH_KEY_CONTENT:-$SSH_KEY_CONTENT_PEM}"
  umask 077
  echo "$KEY_MATERIAL" > "$KEY_FILE"
  chmod 600 "$KEY_FILE"
else
  echo "No SSH key material provided; expecting key to exist at $KEY_FILE or via SSH agent." >&2
fi

cat > "$ENV_FILE" <<ENV
export SSH_HOST=${SSH_HOST_CORE}
export SSH_HOST_CORE=${SSH_HOST_CORE}
export SSH_HOST_DB=${SSH_HOST_DB}
export SSH_HOST_LB=${SSH_HOST_LB}
export SSH_USER=${SSH_USER}
export SSH_PORT=${SSH_PORT}
export SSH_KEY_PATH=${KEY_FILE}
ENV

echo "Wrote ${ENV_FILE} for Chef." >&2
echo "Ensure SSH hosts map to the correct Kitchen suites (core/db/load-balancer)." >&2
