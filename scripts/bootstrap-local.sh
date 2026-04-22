#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_ROOT="${ROOT_DIR}/runtime-data/Users/Shared/HealthOS"

mkdir -p "${DATA_ROOT}"/{system,users,services,agents,runtimes,models,network,backups,logs}
mkdir -p "${DATA_ROOT}/runtimes"/{aaci,async,user-agent}
mkdir -p "${DATA_ROOT}/models"/{registry,adapters,evaluations,datasets,providers}
mkdir -p "${DATA_ROOT}/network"/{mesh,certs,policies}

echo "HealthOS runtime-data scaffold created at: ${DATA_ROOT}"
echo "Next:"
echo "  1. review docs/architecture"
echo "  2. provision PostgreSQL"
echo "  3. apply sql/migrations/001_init.sql"
