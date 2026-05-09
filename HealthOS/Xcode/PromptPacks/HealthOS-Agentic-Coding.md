# HealthOS Agentic Coding Prompt Pack

Use this prompt pack for Xcode 26 agentic coding or another external coding assistant working on this repository.

Mission:

- Preserve HealthOS as the whole platform.
- Keep Core law, GOS/runtimes, Boundary, Stage, Custom, and Constructor roles separate.
- Make the smallest coherent change that satisfies the assigned work unit.
- Do not change runtime behavior during structural work unless the work unit explicitly asks for behavior.

Required reading:

- `AGENTS.md`
- `CLAUDE.md`
- `README.md`
- `HealthOS/README.md`
- `HealthOS/Xcode/Visible-Construction-Support.md`
- `HealthOS/Shared/docs/execution/README.md`
- `HealthOS/Shared/docs/execution/00-master-plan.md`
- `HealthOS/Shared/docs/execution/01-agent-operating-protocol.md`
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
- relevant `HealthOS/Shared/docs/execution/todo/*.md`
- relevant `HealthOS/Shared/docs/architecture/*.md`
- relevant tier README under `HealthOS/`

Forbidden moves:

- Do not move consent, habilitation, gate, finality, provenance, audit, or storage law out of Core.
- Do not treat GOS, AACI, MSR, providers, Boundary, Stages, or Constructor tooling as constitutional authority.
- Do not treat `HealthOS/Constructor` as Tier 5, runtime, clinical automation, merge authority, or production scheduler.
- Do not hide or drop `HealthOS/Constructor` or `HealthOS/Support` from Xcode navigation. They are required engineering/support surfaces.
- Do not introduce fictitious clinical stories, real-patient examples, or maturity claims.
- Do not expose raw direct identifiers in app-facing surfaces.
- Do not commit provider secrets or local-only provider config.
- Do not treat Create ML, Core ML, or MLX work under `Support` as approved provider runtime behavior without ModelGovernance, provenance, and no-real-patient-data evidence.

Validation:

- Structural Swift work: `cd HealthOS && swift package dump-package && swift build && swift test`
- Xcode listing: `xcodebuild -list -workspace HealthOS.xcworkspace`
- Layer schemes: `cd HealthOS && xcodebuild -scheme HealthOS-Providers -destination platform=macOS test`, `HealthOS-Construction`, and `HealthOS-Support` when those surfaces change.
- Repo gates: `make validate-docs`, `make validate-schemas`, `make validate-contracts`, `git diff --check`
- Smoke when runnable surfaces change: `make smoke-cli`, `make smoke-scribe`, `make smoke-veridia`, `make smoke-cloudclinic`

Report format:

- Work unit classification by tier or external construction class.
- Files changed by tier.
- Validation commands run and exact pass/fail result.
- Residual gaps, blockers, or TODOs without invented certainty.
