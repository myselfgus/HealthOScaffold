#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "[schema-validate] ERROR: $*" >&2
  exit 1
}

critical_schemas=(
  "schemas/governed-operational-spec.schema.json"
  "schemas/governed-operational-spec-authoring.schema.json"
  "schemas/governed-operational-spec-bundle-manifest.schema.json"
  "schemas/governed-operational-spec-review-record.schema.json"
  "schemas/governed-operational-spec-lifecycle-audit.schema.json"
  "schemas/contracts/runtime-lifecycle.schema.json"
  "schemas/contracts/backup-restore-retention-export-dr-governance.schema.json"
  "schemas/contracts/regulatory-interoperability-signature-emergency-governance.schema.json"
)
for s in "${critical_schemas[@]}"; do
  [[ -f "$s" ]] || fail "critical schema missing: $s"
done

validated=0
while IFS= read -r schema_file; do
  python -m json.tool "$schema_file" >/dev/null
  validated=$((validated + 1))
done < <(rg --files schemas -g '*.json' | sort)

echo "[schema-validate] OK: validated JSON syntax for ${validated} schema files"
