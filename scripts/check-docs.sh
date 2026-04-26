#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "[docs-check] ERROR: $*" >&2
  exit 1
}

required_files=(
  "README.md"
  "AGENTS.md"
  "CLAUDE.md"
  "docs/execution/README.md"
  "docs/execution/00-master-plan.md"
  "docs/execution/01-agent-operating-protocol.md"
  "docs/execution/02-status-and-tracking.md"
  "docs/execution/06-scaffold-coverage-matrix.md"
  "docs/execution/10-invariant-matrix.md"
)

for f in "${required_files[@]}"; do
  [[ -f "$f" ]] || fail "required file missing: $f"
done

[[ -f "docs/execution/11-current-maturity-map.md" ]] || fail "missing maturity map: docs/execution/11-current-maturity-map.md"
[[ -f "docs/execution/12-next-agent-handoff.md" ]] || fail "missing handoff: docs/execution/12-next-agent-handoff.md"

mapfile -t referenced_docs < <(rg -o --no-filename "docs/[A-Za-z0-9_./-]+\\.md" README.md AGENTS.md CLAUDE.md | sort -u)
for doc in "${referenced_docs[@]}"; do
  [[ -f "$doc" ]] || fail "referenced doc not found: $doc"
done

mapfile -t make_targets_in_docs < <(rg -o --no-filename "make [a-zA-Z0-9_-]+" README.md AGENTS.md CLAUDE.md docs/execution/12-next-agent-handoff.md | awk '{print $2}' | sort -u)
mapfile -t make_targets_defined < <(awk -F: '/^[a-zA-Z0-9_.-]+:/ {print $1}' Makefile | sort -u)

for target in "${make_targets_in_docs[@]}"; do
  if ! printf '%s\n' "${make_targets_defined[@]}" | grep -qx "$target"; then
    fail "documented make target not found in Makefile: $target"
  fi
done

if rg -n "no tests configured" README.md AGENTS.md CLAUDE.md docs/execution/README.md >/dev/null; then
  fail "found stale claim: 'no tests configured'"
fi

if rg -n "(is|are) production-ready" README.md AGENTS.md CLAUDE.md docs/execution/README.md >/dev/null; then
  fail "found explicit production-ready claim"
fi

echo "[docs-check] OK: required docs and references are consistent"
