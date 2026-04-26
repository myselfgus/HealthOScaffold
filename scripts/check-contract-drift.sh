#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "[contract-drift] ERROR: $*" >&2
  exit 1
}

required_paths=(
  "schemas/governed-operational-spec.schema.json"
  "schemas/governed-operational-spec-authoring.schema.json"
  "schemas/governed-operational-spec-bundle-manifest.schema.json"
  "schemas/contracts/runtime-lifecycle.schema.json"
  "schemas/contracts/async-job.schema.json"
  "swift/Sources/HealthOSCore/StorageContracts.swift"
  "swift/Sources/HealthOSCore/ActorModel.swift"
  "swift/Sources/HealthOSCore/AsyncRuntimeJobs.swift"
  "swift/Sources/HealthOSCore/GovernedOperationalSpec.swift"
  "swift/Sources/HealthOSCore/GOSFileBackedRegistry.swift"
  "swift/Sources/HealthOSFirstSliceSupport/FirstSliceRunner.swift"
  "ts/packages/contracts/src/index.ts"
  "ts/packages/healthos-gos-tooling/src/index.ts"
  "sql/migrations/001_init.sql"
  "docs/execution/10-invariant-matrix.md"
  "docs/execution/skills/documentation-drift-skill.md"
)

for path in "${required_paths[@]}"; do
  [[ -f "$path" ]] || fail "missing required artifact: $path"
done

# Storage layers must remain represented in Swift + TS + SQL.
for layer in "direct-identifiers" "operational-content" "governance-metadata" "derived-artifacts" "reidentification-mapping"; do
  rg -q "$layer" swift/Sources/HealthOSCore/StorageContracts.swift || fail "missing storage layer '$layer' in Swift storage contracts"
  rg -q "$layer" ts/packages/contracts/src/index.ts || fail "missing storage layer '$layer' in TS contracts"
done
rg -q "direct_identifier_kind" sql/migrations/001_init.sql || fail "missing direct identifier SQL column contract"

# Runtime lifecycle states must be present in schema + Swift + TS.
for lifecycle_state in "booting" "ready" "active" "failed"; do
  rg -q "\"$lifecycle_state\"" schemas/contracts/runtime-lifecycle.schema.json || fail "missing runtime lifecycle state '$lifecycle_state' in schema"
  rg -q "case $lifecycle_state" swift/Sources/HealthOSCore/ActorModel.swift || fail "missing runtime lifecycle state '$lifecycle_state' in Swift ActorModel"
  rg -q "\"$lifecycle_state\"" ts/packages/contracts/src/index.ts || fail "missing runtime lifecycle state '$lifecycle_state' in TS contracts"
done

# GOS lifecycle presence checks across schema/Swift/TS.
for gos_state in "draft" "active" "revoked"; do
  rg -q "\"$gos_state\"" schemas/governed-operational-spec-bundle-manifest.schema.json || fail "missing GOS state '$gos_state' in bundle manifest schema"
  rg -q "case $gos_state" swift/Sources/HealthOSCore/GovernedOperationalSpec.swift || fail "missing GOS state '$gos_state' in Swift governed spec contracts"
  rg -q "\"$gos_state\"" ts/packages/contracts/src/index.ts || fail "missing GOS state '$gos_state' in TS contracts"
done

echo "[contract-drift] OK: baseline cross-layer contract presence checks passed"
