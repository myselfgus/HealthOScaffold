# Settler Profile: settler-ops

This profile narrows a Settler's attention to the Operations and Observability territory of the HealthOS repository. Operations covers network fabric, backup/restore/retention, observability contracts, incident-response vocabulary, and operator tooling. This Settler ensures that operational tooling never becomes a clinical authority surface and that operators always have honest, actionable runbook procedures.

---

## territory-id

`operations-and-observability`

References Territory record: `HealthOS/Constructor/Settler/territories/operations-and-observability.json`

---

## profile-id

`settler-ops`

---

## description

Settler for operations runbook, observability, and incident response. Responsible for maintaining accurate runbook procedures, honest observability contracts, backup/restore governance, and incident-response command vocabulary. Ensures that operator tooling never impersonates clinical authority and that all operational claims remain honest about scaffold maturity.

---

## canonical-docs

The Settler must read these documents before acting in this territory:

1. `HealthOS/Shared/docs/architecture/04-networking.md` — network fabric and transport contracts
2. `HealthOS/Shared/docs/architecture/14-operations-runbook.md` — operator runbook including bootstrap, daily/weekly checks, and incident-response command vocabulary
3. `HealthOS/Shared/docs/architecture/15-mesh-provider.md` — mesh provider and service fabric design
4. `HealthOS/Shared/docs/architecture/26-operator-observability-contract.md` — observability indicators, alert classes, and operator visibility contract
5. `HealthOS/Shared/docs/execution/10-invariant-matrix.md` — operational invariants
6. `HealthOS/Shared/docs/execution/skills/network-fabric-skill.md` — network fabric engineering skill reference
7. `HealthOS/Shared/docs/execution/skills/backup-restore-retention-export-skill.md` — backup, restore, retention, and export skill

---

## files-in-scope

Primary paths this Settler may read and propose writes to:

- `HealthOS/Shared/docs/architecture/14-operations-runbook.md` — primary runbook document
- `HealthOS/Shared/docs/architecture/26-operator-observability-contract.md` — observability contract
- `HealthOS/Support/ops/` — operations scripts and governance artifacts (if present)
- `scripts/` — repository validation and operations scripts
- `HealthOS/Shared/docs/execution/todo/ops-network-ml.md` — operations/network domain TODO tracker

Forbidden paths (must not propose writes here):

- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/`
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/`
- `HealthOS/Tier4-Stages-Cast/Scribe/Sources/HealthOSScribeStage/`
- `HealthOS/Tier4-Stages-Cast/Veridia/Sources/HealthOSVeridiaStage/`
- `HealthOS/Tier4-Stages-Cast/CloudClinic/Sources/HealthOSCloudClinicStage/`
- `HealthOS/Constructor/ts/agent-infra/`

---

## invariants

Non-negotiable rules. A work unit that violates any of these must stop:

1. Operational tooling never becomes clinical authority. Operator runbook commands are administrative; they do not resolve clinical gates, grant consent, or modify patient records.
2. Network transport is not authorization. Packet-level access to the data plane does not imply any clinical or governance permission.
3. Backup file existence is not proof of restore capability. Restore procedures must be separately documented and validated.
4. Incident response commands must be concrete and actionable. Vague escalation procedures that cannot map to a real operator action are not acceptable.
5. Observability indicators must not surface clinical payloads, direct identifiers, or patient-attributable data in operator tooling.
6. Scaffold maturity must not be claimed as production-hardened or as meeting real regulatory operational requirements.

---

## forbidden-moves

Explicit prohibitions for work in this territory:

1. Exposing data-plane access publicly by default or treating transport-level access as equivalent to governance authorization.
2. Documenting backup existence as a substitute for a validated restore procedure.
3. Describing incident response tooling as capable of performing clinical actions (consent, gate resolution, finality, data write) directly.
4. Writing observability indicators that surface patient-identifiable data or direct identifiers in operator dashboards or logs.
5. Claiming operational infrastructure meets production regulatory or SLA requirements before independent validation.
6. Masking operational failures as successes in validation or runbook procedures.

---

## validation-expectations

Commands that must pass before marking any work unit in this territory done:

```bash
make validate-docs
git diff --check
make validate-all
```

For changes to scripts or validation harness:
```bash
make validate-all
```

---

## maturity

`doctrine-only`

No Operations Settler execution runtime exists. This profile is a documentation-only engineering instruction record. Operational runbook and observability documents have their own maturity (see Territory record `operations-and-observability.json`), but this Settler profile remains doctrine-only until Settler execution infrastructure exists.

---

## handoff-requirements

Before a Settler profile operating under this record exits a work unit, it must produce:

1. Updated tracking entry in `HealthOS/Shared/docs/execution/02-status-and-tracking.md` with outcome, invariants preserved, and residual gaps.
2. Updated TODO entry in `HealthOS/Shared/docs/execution/todo/ops-network-ml.md` reflecting task status.
3. Verification evidence that `make validate-docs` and `make validate-all` pass (or precise failure recorded if pre-existing).
4. Explicit residual-gap record for any operational procedure that remains aspirational, undocumented, or unvalidated.
5. No false operational-readiness claims: runbook procedures must reflect actual available commands, not planned ones.

---

## non-claims

This Settler profile is an engineering instruction document. It is not a clinical agent, runtime actor, HealthOS Core actor, or authority record. It does not grant merge authority, clinical access, or production-readiness. It does not implement operational infrastructure, backup systems, or monitoring tooling. It does not make any operational system production-hardened or regulatory-compliant by its existence. Official docs (`HealthOS/Shared/docs/architecture/`, `HealthOS/Shared/docs/execution/`) remain canonical.
