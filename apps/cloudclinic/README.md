# CloudClinic

Service operations Stage for HealthOS. CloudClinic surfaces professional service-context operations via `HealthOSBoundary`. It never defines Core law or holds clinical authority.

**Architecture:** `docs/architecture/13-cloudclinic.md`
**Executable surface:** [`swift/Sources/HealthOSCloudClinicStage/`](../../swift/Sources/HealthOSCloudClinicStage/)
**Design surface:** [`HealthOSDesignSystem/ui_kits/cloudclinic/`](../../HealthOSDesignSystem/ui_kits/cloudclinic/)
**Runtime:** `HealthOSServiceRuntime` (Tier 2) via `HealthOSBoundary`

## Screens

| Screen | Purpose |
| :--- | :--- |
| Service dashboard | Service-context overview, active session summary |
| Patient queue | Governed patient queue — no raw identifiers exposed |
| Patient registry | Mediated patient record access |
| Pending drafts and gates | Pending final artifacts awaiting gate resolution |
| Document operations | Governed document lifecycle |
| Staff activity | Operator audit trail |

## Maturity

Scaffold placeholder only. `HealthOSCloudClinicStage` executable is present for product-graph representation and smoke-test baseline (`--smoke-test` exits 0). No final UI shell, no session behavior, no clinical authority.

`HealthOSCloudClinicStage` correctly imports `HealthOSBoundary` only — no direct Tier 1/2 dependencies. Final service-operations wiring is BLOCKED pending `HealthOSServiceRuntime` and `HealthOSBoundary` facade implementation.
