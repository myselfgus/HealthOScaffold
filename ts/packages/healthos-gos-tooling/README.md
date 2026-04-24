# @healthos/gos-tooling

TypeScript tooling for Governed Operational Spec (GOS) authoring, canonicalization, schema validation, cross-reference validation, and bundle generation.

## Current scope

This package currently provides:
- YAML parsing for GOS authoring documents
- deterministic canonicalization into compiled JSON shape
- authoring-schema validation
- compiled-schema validation
- cross-reference and simple invariant validation
- compiler reports with source provenance hashes
- a CLI for `validate`, `compile`, and `bundle`

## Current non-goals

This package does not yet provide:
- semantic interpretation of source text
- reviewed scenario packs
- runtime execution
- app-facing policy interpretation
- sovereign law enforcement

## Commands

After installing workspace dependencies:

```bash
npm run build --workspace @healthos/gos-tooling
```

CLI usage:

```bash
healthos-gos validate path/to/spec.yaml
healthos-gos compile path/to/spec.yaml path/to/spec.json
healthos-gos bundle path/to/spec.yaml path/to/output-dir
```

## Bundle output

The `bundle` command writes a draft compiled bundle directory containing:
- `manifest.json`
- `spec.json`
- `compiler-report.json`
- `source-provenance.json`

This is a compile artifact, not an activation decision.
Activation remains a separate HealthOS runtime/storage concern.
