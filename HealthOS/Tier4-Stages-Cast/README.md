# Tier 4 - Stages Cast

Tier 4 contains governed application consumers inside HealthOS. Scribe, Veridia, CloudClinic, and future first-party or third-party applications are Stages; they never define Core law, GOS authority, runtime behavior, or the HealthOS ontology.

Cast refers to the Stage-side actor/agent domain still to be defined. It does not create a new tier or authority category.

Current contents:

- `Scribe/` - `HealthOSScribeStage`, resources, Custom definition, and smoke surface.
- `Veridia/` - `HealthOSVeridiaStage`, resources, Custom definition, and smoke surface.
- `CloudClinic/` - `HealthOSCloudClinicStage`, resources, Custom definition, and smoke surface.
- `AppDocs/` - Stage-facing documentation migrated from the historical `apps/` directory.

Stage work advances only after the mediated surface it consumes is implemented and stable, and after the relevant Custom is complete. If the required Tier 1-3 surface is absent or unstable, the Stage task is blocked rather than patched around the gap.
