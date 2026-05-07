# CloudClinic

Service operations app for HealthOS. CloudClinic is a Tier 5 reference app — it surfaces professional service-context operations via `HealthOSAppBoundary`. It never defines Core law or holds clinical authority.

**Architecture:** `docs/architecture/13-cloudclinic.md`  
**Executable surface:** [`swift/Sources/HealthOSCloudClinicApp/`](../../swift/Sources/HealthOSCloudClinicApp/)  
**Design surface:** [`HealthOSDesignSystem/ui_kits/cloudclinic/`](../../HealthOSDesignSystem/ui_kits/cloudclinic/)  
**Runtime:** `HealthOSServiceRuntime` (Tier 2) via `HealthOSAppBoundary`

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

Scaffold placeholder only. `HealthOSCloudClinicApp` executable is present for product-graph representation and smoke-test baseline (`--smoke-test` exits 0). No final UI shell, no session behavior, no clinical authority.

`HealthOSCloudClinicApp` correctly imports `HealthOSAppBoundary` only — no direct Tier 1/2 dependencies. Final service-operations wiring is BLOCKED pending `HealthOSServiceRuntime` and `HealthOSAppBoundary` facade implementation.
