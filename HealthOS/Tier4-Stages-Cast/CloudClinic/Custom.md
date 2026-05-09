# CloudClinic Custom

Status: needs-review.

CloudClinic is a governed Stage consumer inside HealthOS. Its current implementation is a smoke-test scaffold for service-operations surfaces; it is not a production-ready clinic application.

Current consumed surfaces:

- Primary surface: `HealthOSBoundary`.
- Custom gap: exact CloudClinic facade/envelope needs a focused follow-up before broader Stage work advances.

Prohibitions:

- CloudClinic must not define Core law, GOS authority, runtime authority, storage law, finality, or provider truth.
- CloudClinic must not imply real provider, claims, billing, interoperability, regulatory, or EHR integration.
- CloudClinic must not expose raw direct identifiers in app-facing surfaces.
