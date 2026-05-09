# Scribe Custom

Status: needs-review.

Scribe is a governed Stage consumer inside HealthOS. Its current implementation is a minimal SwiftUI and smoke-test surface for the first slice; it is not production-ready clinical software.

Current consumed surfaces:

- Primary intended surface: `HealthOSBoundary`.
- Current scaffold exceptions: direct `HealthOSCore` and `HealthOSSessionRuntime` dependencies remain documented as TODOs in `HealthOS/Package.swift` until the Boundary facade is complete.

Prohibitions:

- Scribe must not define Core law, GOS authority, runtime authority, storage law, finality, or provider truth.
- Scribe must not persist stub/provider output as real clinical output.
- Scribe must not expose raw direct identifiers in app-facing surfaces.
