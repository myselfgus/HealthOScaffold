#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stage_root="$root/HealthOS/Tier4-Stages-Cast"

forbidden_products=(
  HealthOSCore
  HealthOSGOS
  HealthOSAACI
  HealthOSMSR
  HealthOSProviders
  HealthOSAsyncRuntime
  HealthOSUserAgentRuntime
  HealthOSServiceRuntime
  HealthOSSessionRuntime
)

forbidden_apple_authority_imports=(
  CloudKit
  FoundationModels
  CoreML
  NaturalLanguage
  Network
  ServiceManagement
  XPC
)

for stage in Scribe Veridia CloudClinic; do
  package="$stage_root/$stage/Package.swift"
  custom="$stage_root/$stage/Custom.md"
  source_dir="$stage_root/$stage/Sources/$stage"

  test -f "$package" || { echo "[stage-package-check] missing $package"; exit 1; }
  test -f "$custom" || { echo "[stage-package-check] missing $custom"; exit 1; }
  test -d "$source_dir" || { echo "[stage-package-check] missing $source_dir"; exit 1; }

  rg -q '\.product\(name: "HealthOSBoundary"' "$package" || {
    echo "[stage-package-check] $stage must depend on HealthOSBoundary"
    exit 1
  }
  rg -q '\.product\(name: "CustomSDK"' "$package" || {
    echo "[stage-package-check] $stage must depend on CustomSDK"
    exit 1
  }

  for product in "${forbidden_products[@]}"; do
    if rg -n "\\.product\\(name: \"$product\"" "$package"; then
      echo "[stage-package-check] $stage depends on forbidden Tier 1/2 product $product; use HealthOSBoundary and CustomSDK only"
      exit 1
    fi
    if rg -n "^(@testable[[:space:]]+)?import[[:space:]]+$product$" "$source_dir"; then
      echo "[stage-package-check] $stage imports forbidden HealthOS module $product; use HealthOSBoundary and CustomSDK only"
      exit 1
    fi
  done

  for module in "${forbidden_apple_authority_imports[@]}"; do
    if rg -n "^(@testable[[:space:]]+)?import[[:space:]]+$module$" "$source_dir"; then
      echo "[stage-package-check] $stage imports Apple authority framework $module directly; request substrate capability through Custom/Boundary"
      exit 1
    fi
  done

  if rg -n '^(@testable[[:space:]]+)?import[[:space:]]+SwiftData$' "$source_dir"; then
    if ! rg -qi 'projection|cache' "$custom" "$source_dir/README.md" 2>/dev/null; then
      echo "[stage-package-check] $stage imports SwiftData but does not document projection/cache-only usage"
      exit 1
    fi
    if rg -qi 'canonical custody' "$custom" "$source_dir/README.md" 2>/dev/null && ! rg -qi 'never canonical custody' "$custom" "$source_dir/README.md" 2>/dev/null; then
      echo "[stage-package-check] $stage SwiftData docs must say never canonical custody"
      exit 1
    fi
  fi

  if rg -n 'HealthOSScribeStage|HealthOSVeridiaStage|HealthOSCloudClinicStage' "$source_dir" "$package"; then
    echo "[stage-package-check] $stage uses forbidden HealthOS*Stage technical naming"
    exit 1
  fi
done

if rg -n 'HealthOSScribeStage|HealthOSVeridiaStage|HealthOSCloudClinicStage' "$root/HealthOS/Package.swift"; then
  echo "[stage-package-check] platform Package.swift must not expose Stage executables"
  exit 1
fi

echo "[stage-package-check] OK: Stage packages are separate and Boundary/CustomSDK-only with Apple authority imports blocked"
