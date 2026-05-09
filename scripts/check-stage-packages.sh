#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stage_root="$root/HealthOS/Tier4-Stages-Cast"

for stage in Scribe Veridia CloudClinic; do
  package="$stage_root/$stage/Package.swift"
  custom="$stage_root/$stage/Custom.md"
  source_dir="$stage_root/$stage/Sources/$stage"

  test -f "$package" || { echo "[stage-package-check] missing $package"; exit 1; }
  test -f "$custom" || { echo "[stage-package-check] missing $custom"; exit 1; }
  test -d "$source_dir" || { echo "[stage-package-check] missing $source_dir"; exit 1; }

  if grep -R "import HealthOSCore\|import HealthOSSessionRuntime\|import HealthOSAACI\|import HealthOSGOS\|import HealthOSProviders\|import HealthOSMSR" "$source_dir"; then
    echo "[stage-package-check] $stage imports Tier 1/2 modules directly; use HealthOSBoundary and CustomSDK only"
    exit 1
  fi

  if grep -R "HealthOSScribeStage\|HealthOSVeridiaStage\|HealthOSCloudClinicStage" "$source_dir" "$package"; then
    echo "[stage-package-check] $stage uses forbidden HealthOS*Stage technical naming"
    exit 1
  fi
done

if grep -n "HealthOSScribeStage\|HealthOSVeridiaStage\|HealthOSCloudClinicStage" "$root/HealthOS/Package.swift"; then
  echo "[stage-package-check] platform Package.swift must not expose Stage executables"
  exit 1
fi

echo "[stage-package-check] OK: Stage packages are separate and Boundary/CustomSDK-only"
