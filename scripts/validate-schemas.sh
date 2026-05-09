#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
SCHEMA_ROOT="HealthOS/Tier1-Mestral-Core/Schemas"

fail() {
  echo "[schema-validate] ERROR: $*" >&2
  exit 1
}

critical_schemas=(
  "${SCHEMA_ROOT}/governed-operational-spec.schema.json"
  "${SCHEMA_ROOT}/governed-operational-spec-authoring.schema.json"
  "${SCHEMA_ROOT}/governed-operational-spec-bundle-manifest.schema.json"
  "${SCHEMA_ROOT}/governed-operational-spec-review-record.schema.json"
  "${SCHEMA_ROOT}/governed-operational-spec-lifecycle-audit.schema.json"
  "${SCHEMA_ROOT}/contracts/runtime-lifecycle.schema.json"
  "${SCHEMA_ROOT}/contracts/backup-restore-retention-export-dr-governance.schema.json"
  "${SCHEMA_ROOT}/contracts/regulatory-interoperability-signature-emergency-governance.schema.json"
)
for s in "${critical_schemas[@]}"; do
  [[ -f "$s" ]] || fail "critical schema missing: $s"
done

validated=0
while IFS= read -r schema_file; do
  python3 -m json.tool "$schema_file" >/dev/null
  validated=$((validated + 1))
done < <(rg --files "${SCHEMA_ROOT}" -g '*.json' | sort)

echo "[schema-validate] OK: validated JSON syntax for ${validated} schema files"
