# @healthos/gos-tooling

TypeScript scaffolding for Governed Operational Spec (GOS) authoring, canonicalization, and validation.

## Current scope

This package currently provides:
- YAML parsing for GOS authoring documents
- deterministic canonicalization into compiled JSON shape
- minimal cross-reference validation scaffold
- a CLI for `validate` and `compile`

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
```
