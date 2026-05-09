# Local validation checklist

## Purpose

This checklist defines the local validation pass that should be run after the current GOS stabilization wave.

## Why this exists

A meaningful part of the recent GOS work was applied directly through GitHub-side edits.
That means architectural coherence was preserved, but local build/runtime confirmation still needs to happen explicitly.

## Run order

### 1. Bootstrap local runtime data
```bash
./scripts/bootstrap-local.sh
```
Confirm:
- runtime-data tree exists
- `system/HealthOS/Tier2-GOS-Runtimes/GOS/registry/aaci.first-slice.json` exists
- `system/HealthOS/Tier2-GOS-Runtimes/GOS/bundles/aaci.first-slice--0.1.0-reviewed-001/` exists

### 2. Build TypeScript GOS tooling
```bash
cd HealthOS/Constructor/ts
npm install
npm run build --workspace @healthos/gos-tooling
```
Confirm:
- package builds without type errors

### 3. Validate the authoring spec
```bash
cd HealthOS/Constructor/ts
node packages/healthos-gos-tooling/dist/cli.js validate ../HealthOS/Tier2-GOS-Runtimes/GOS/specs/aaci.first-slice.gos.yaml
```
Confirm:
- authoring schema passes
- compiled schema passes
- cross-reference validation passes
- evidence-hook validation passes

### 4. Bundle the authoring spec locally
```bash
cd HealthOS/Constructor/ts
node packages/healthos-gos-tooling/dist/cli.js bundle ../HealthOS/Tier2-GOS-Runtimes/GOS/specs/aaci.first-slice.gos.yaml ../tmp-gos-bundles
```
Confirm:
- bundle emits manifest/spec/compiler-report/source-provenance files

### 5. Build Swift packages
```bash
cd HealthOS
swift build
```
Confirm:
- `HealthOSCore`
- `HealthOSAACI`
- `HealthOSSessionRuntime`
- related targets compile cleanly

### 6. Smoke test CLI path
```bash
cd HealthOS
swift run HealthOSCLI
```
Confirm:
- first-slice path still runs
- no regression in draft/gate/final document path

### 7. Smoke test Scribe app shell
```bash
cd HealthOS/Tier4-Stages-Cast/Scribe
swift run Scribe --smoke-test
```
Confirm:
- app shell still boots
- no bridge regression

### 8. Check Stage package separation
```bash
./scripts/check-stage-packages.sh
```
Confirm:
- each Stage owns a `Package.swift`
- each Stage carries `Custom.md`
- Stage sources import only `HealthOSBoundary` and `CustomSDK` from the platform package

## Extra check

Inspect first-slice outputs and confirm that, when the active bootstrap bundle is present, persisted draft metadata and related event/provenance paths reflect the active GOS bundle mediation.

## Current status

At the time this checklist was added, this local validation pass was still pending execution.
