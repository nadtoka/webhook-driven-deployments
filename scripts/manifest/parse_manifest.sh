#!/usr/bin/env bash
set -euo pipefail

# Parse an XML manifest (default: sample-manifest.xml) and emit build.env with exported tags.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_PATH="${1:-"${SCRIPT_DIR}/sample-manifest.xml"}"
OUTPUT_FILE="${SCRIPT_DIR}/../../build.env"

if [[ ! -f "$MANIFEST_PATH" ]]; then
  echo "Manifest file not found: ${MANIFEST_PATH}" >&2
  exit 1
fi

read_tags_with_xmlstarlet() {
  xmlstarlet sel -t \
    -m '/manifest/component[field="BE_TAG"]/tag' -v '.' -n \
    -m '/manifest/component[field="FE_TAG"]/tag' -v '.' -n \
    -m '/manifest/component[field="INFRA_TAG"]/tag' -v '.' -n \
    "$MANIFEST_PATH"
}

read_tags_with_python() {
  python - "$MANIFEST_PATH" <<'PY'
import sys
import xml.etree.ElementTree as ET

path = sys.argv[1]
tree = ET.parse(path)
root = tree.getroot()
lookup = {child.findtext('field'): child.findtext('tag') for child in root.findall('component')}
print(lookup.get('BE_TAG', ''))
print(lookup.get('FE_TAG', ''))
print(lookup.get('INFRA_TAG', ''))
PY
}

if command -v xmlstarlet >/dev/null 2>&1; then
  mapfile -t values < <(read_tags_with_xmlstarlet)
else
  mapfile -t values < <(read_tags_with_python "$MANIFEST_PATH")
fi

BE_TAG=${values[0]:-}
FE_TAG=${values[1]:-}
INFRA_TAG=${values[2]:-}

{
  echo "export BE_TAG=${BE_TAG}"
  echo "export FE_TAG=${FE_TAG}"
  echo "export INFRA_TAG=${INFRA_TAG}"
  if [[ -n "${MANIFEST_TAG:-}" ]]; then
    echo "export MANIFEST_TAG=${MANIFEST_TAG}"
  fi
} > "$OUTPUT_FILE"

echo "Wrote ${OUTPUT_FILE} with manifest tags."
