# Veridia Custom

Status: needs-review.

Veridia is a governed Stage consumer inside HealthOS. Its current implementation is a smoke-test surface for patient identity/session boundary work; it is not a production-ready patient application.

Current consumed surfaces:

- Primary intended surface: `HealthOSBoundary`.
- Current scaffold exception: direct `HealthOSCore` dependency remains documented as a TODO in `HealthOS/Package.swift` until the Boundary facade owns the required app-safe types.

Prohibitions:

- Veridia must not define Core law, GOS authority, runtime authority, storage law, finality, or provider truth.
- Veridia must not treat scaffold identity/session behavior as a real provider, regulatory, or EHR integration.
- Veridia must not expose raw direct identifiers in app-facing surfaces.
