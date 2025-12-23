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

SSH_HOST=$(echo "$OUTPUT_JSON" | jq -er '.ssh_host.value // empty' || true)
SSH_USER=$(echo "$OUTPUT_JSON" | jq -er '.ssh_user.value // empty' || true)
SSH_PORT=$(echo "$OUTPUT_JSON" | jq -er '.ssh_port.value // empty' || true)
SSH_KEY_CONTENT=$(echo "$OUTPUT_JSON" | jq -er '.ssh_private_key.value // empty' || true)
SSH_KEY_CONTENT_PEM=$(echo "$OUTPUT_JSON" | jq -er '.ssh_private_key_pem.value // empty' || true)
SSH_KEY_PATH_OUTPUT=$(echo "$OUTPUT_JSON" | jq -er '.ssh_key_path.value // empty' || true)

CHEF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$CHEF_DIR/.env"
KEY_FILE="$CHEF_DIR/id_rsa"

if [[ -z "$SSH_HOST" || -z "$SSH_USER" || -z "$SSH_PORT" ]]; then
  echo "Missing required outputs: ssh_host=${SSH_HOST:-unset} ssh_user=${SSH_USER:-unset} ssh_port=${SSH_PORT:-unset}" >&2
  exit 1
fi

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
export SSH_HOST=${SSH_HOST}
export SSH_USER=${SSH_USER}
export SSH_PORT=${SSH_PORT}
export SSH_KEY_PATH=${KEY_FILE}
ENV

echo "Wrote ${ENV_FILE} for Chef." >&2
echo "TODO: replace placeholder Terraform with real infrastructure outputs." >&2
