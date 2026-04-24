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
- `system/gos/registry/aaci.first-slice.json` exists
- `system/gos/bundles/aaci.first-slice--0.1.0-reviewed-001/` exists

### 2. Build TypeScript GOS tooling
```bash
cd ts
npm install
npm run build --workspace @healthos/gos-tooling
```
Confirm:
- package builds without type errors

### 3. Validate the authoring spec
```bash
cd ts
node packages/healthos-gos-tooling/dist/cli.js validate ../gos/specs/aaci.first-slice.gos.yaml
```
Confirm:
- authoring schema passes
- compiled schema passes
- cross-reference validation passes
- evidence-hook validation passes

### 4. Bundle the authoring spec locally
```bash
cd ts
node packages/healthos-gos-tooling/dist/cli.js bundle ../gos/specs/aaci.first-slice.gos.yaml ../tmp-gos-bundles
```
Confirm:
- bundle emits manifest/spec/compiler-report/source-provenance files

### 5. Build Swift packages
```bash
cd swift
swift build
```
Confirm:
- `HealthOSCore`
- `HealthOSAACI`
- `HealthOSFirstSliceSupport`
- related targets compile cleanly

### 6. Smoke test CLI path
```bash
cd swift
swift run HealthOSCLI
```
Confirm:
- first-slice path still runs
- no regression in draft/gate/final document path

### 7. Smoke test Scribe app shell
```bash
cd swift
swift run HealthOSScribeApp --smoke-test
```
Confirm:
- app shell still boots
- no bridge regression

## Extra check

Inspect first-slice outputs and confirm that, when the active bootstrap bundle is present, persisted draft metadata and related event/provenance paths reflect the active GOS bundle mediation.

## Current status

At the time this checklist was added, this local validation pass was still pending execution.
