# CloudClinic UI kit

**Status:** Documented surface — no implementation exists yet in the source repo.

CloudClinic is the **service-operations surface** described in `HealthOS/Shared/docs/architecture/40-cloudclinic-service-operations-surface.md`. It hosts service-operations actors (admins, schedulers, billing, integrations) — it is **not** a clinical surface, and it does NOT carry HealthOS Core.

Its role:
- macOS / web operator console for clinic operations: scheduling, queues, billing reconciliation, integration health.
- Bounded mediated access into HealthOS, exclusively via the documented bridge.
- Operations decisions never bypass the law: clinical effectuation belongs to Scribe + HealthOS Core.

This folder contains a brief mockup placeholder (`index.html`). When a real surface lands in the source repo, recreate it here at the same fidelity as the Scribe kit.
