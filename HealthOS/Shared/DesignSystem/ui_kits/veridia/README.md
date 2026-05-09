# Veridia UI kit

**Status:** Scaffolded contract — no implementation exists yet in the source repo.

Veridia is the **patient health identity surface** described in `HealthOS/Shared/docs/architecture/12-veridia.md` and `HealthOS/Shared/docs/architecture/24-veridia-screen-contracts.md`.

Its role:
- The civil person's **mediated** access to their HealthOS-bound health data and consent tokens.
- macOS patient health identity app — mediated, never effectuating.
- Bounded surface: it does NOT carry HealthOS Core; the law remains in HealthOS.
- Veridia is **mediated-only** — it cannot effectuate documents directly; effectuation is gated and stays in the professional surface (Scribe).

This folder contains a brief mockup placeholder (`index.html`). When/if a Swift implementation lands, it should be recreated here following the same fidelity rules as the Scribe kit.
