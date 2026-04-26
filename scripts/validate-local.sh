#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SUMMARY_DIR="runtime-data/validation"
SUMMARY_FILE="${SUMMARY_DIR}/latest-validation-summary.txt"
mkdir -p "$SUMMARY_DIR"

TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

steps=()
failures=()

run_step() {
  local name="$1"
  shift
  echo "[validate-local] >>> ${name}"
  if "$@"; then
    steps+=("PASS | ${name}")
    echo "[validate-local] PASS: ${name}"
  else
    steps+=("FAIL | ${name}")
    failures+=("${name}")
    echo "[validate-local] FAIL: ${name}" >&2
  fi
}

run_step "bootstrap-local" bash ./scripts/bootstrap-local.sh
run_step "validate-docs" bash ./scripts/check-docs.sh
run_step "validate-schemas" bash ./scripts/validate-schemas.sh
run_step "validate-contracts" bash ./scripts/check-contract-drift.sh
run_step "swift-build" make swift-build
run_step "swift-test" make swift-test
if [[ -d ts/node_modules ]]; then
  run_step "ts-build" bash -lc "cd ts && npm run build"
  run_step "ts-test" bash -lc "cd ts && npm test --if-present --workspaces"
else
  steps+=("FAIL | ts-build")
  steps+=("FAIL | ts-test")
  failures+=("ts-build")
  failures+=("ts-test")
  echo "[validate-local] FAIL: ts dependencies missing (ts/node_modules). Run: cd ts && npm install" >&2
fi
run_step "python-check" make python-check
run_step "smoke-cli" make smoke-cli
run_step "smoke-scribe" make smoke-scribe

{
  echo "HealthOS local validation summary"
  echo "timestamp_utc: ${TIMESTAMP}"
  echo "repo_root: ${ROOT_DIR}"
  echo ""
  echo "steps:"
  printf ' - %s\n' "${steps[@]}"
  echo ""
  if ((${#failures[@]} > 0)); then
    echo "overall: FAIL"
    echo "failed_steps:"
    printf ' - %s\n' "${failures[@]}"
  else
    echo "overall: PASS"
  fi
  echo ""
  echo "note: this is local scaffold validation only; it is not production validation or compliance certification."
} > "$SUMMARY_FILE"

echo "[validate-local] summary: ${SUMMARY_FILE}"

if ((${#failures[@]} > 0)); then
  exit 1
fi
