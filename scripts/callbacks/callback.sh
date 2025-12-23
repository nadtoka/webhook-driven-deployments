#!/usr/bin/env bash
set -euo pipefail

STATUS=${1:-}
STAGE=${2:-}
ENV_NAME=${ENV_NAME:-"unknown"}
SERVICE=${TF_VAR_service:-${SERVICE:-"unknown"}}
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [[ -z "$STATUS" || -z "$STAGE" ]]; then
  echo "Usage: $0 <success|failed> <stage>" >&2
  exit 0
fi

payload() {
  cat <<JSON
{"status":"${STATUS}","stage":"${STAGE}","env":"${ENV_NAME}","service":"${SERVICE}","timestamp":"${TIMESTAMP}"}
JSON
}

post_callback() {
  local url="$1"
  echo "Posting callback to ${url}" >&2
  curl -sSf -X POST -H 'Content-Type: application/json' -d "$(payload)" "$url" || true
}

if [[ "$STATUS" == "success" && -n "${CALLBACK_URL_SUCCESS:-}" ]]; then
  post_callback "$CALLBACK_URL_SUCCESS"
elif [[ "$STATUS" == "failed" && -n "${CALLBACK_URL_FAIL:-}" ]]; then
  post_callback "$CALLBACK_URL_FAIL"
else
  echo "Callback: ${STATUS} for ${STAGE} (${ENV_NAME}) service=${SERVICE} at ${TIMESTAMP}" >&2
fi

exit 0
