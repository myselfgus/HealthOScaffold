#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_ROOT="${ROOT_DIR}/runtime-data/Users/Shared/HealthOS"
SOURCE_ROOT="${ROOT_DIR}/bootstrap/gos/system/gos"
TARGET_ROOT="${DATA_ROOT}/system/gos"

mkdir -p "${TARGET_ROOT}/registry"
mkdir -p "${TARGET_ROOT}/bundles"

cp -R "${SOURCE_ROOT}/registry/." "${TARGET_ROOT}/registry/"
cp -R "${SOURCE_ROOT}/bundles/." "${TARGET_ROOT}/bundles/"

echo "Bootstrapped AACI first-slice GOS bundle into: ${TARGET_ROOT}"
echo "Active spec: aaci.first-slice"
echo "Active bundle: aaci.first-slice--0.1.0-reviewed-001"
