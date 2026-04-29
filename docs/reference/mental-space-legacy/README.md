# Mental Space Legacy Reference Scripts

These TypeScript scripts are the original reference implementation of the ASL/VDLP/GEM Mental Space pipeline developed before the Swift `HealthOSMentalSpace` runtime.

They are archived reference implementations.

They are not the active HealthOS pipeline.

## Active pipeline

The active pipeline is:

```text
swift/Sources/HealthOSMentalSpace/
```

The active Swift runtime owns:

- staged execution boundaries
- provider invocation boundaries
- fail-closed dependency validation
- derived artifact construction
- provenance markers
- app-safe Mental Space state

## Canonical prompt contracts

The canonical prompt contracts are extracted into:

```text
swift/Sources/HealthOSMentalSpace/Prompts/
```

Current prompt files:

- `asl-system.md`
- `vdlp-system.md`
- `gem-system.md`

Prompt content must not be altered without explicit re-validation against the clinical validation cohort and an updated validation record.

## Reference status

These scripts may be used to understand:

- historical prompt-engineering decisions
- chunking behavior
- response parsing expectations
- consolidation behavior
- original stage sequencing

They must not be treated as active runtime code.

They must not be run against production data.

They must not be used to bypass HealthOS Core, provider policy, lawfulContext, provenance, or gate requirements.

## Non-claims

This archive does not claim:

- production readiness
- regulatory compliance
- clinical authority
- diagnosis authority
- provider integration readiness
- replacement of the Swift Mental Space Runtime

ASL, VDLP, and GEM outputs remain derived, gated, non-authorizing Mental Space artifacts.
