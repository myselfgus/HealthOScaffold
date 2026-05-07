# Veridia

Veridia is the canonical patient app name and uses patient health identity Stage wording.

Veridia is an initial Stage, not the definition of HealthOS. It consumes Core/runtime-mediated patient health identity surfaces through Boundary.

## Purpose

Veridia is the patient health identity Stage for HealthOS.

Veridia is where the patient interacts with HealthOS for health identity, mediated key custody controls, consent visibility, access trail visibility, owned-data visibility, export controls, and patient agent interaction. All surfaces are Core-mediated; Veridia does not own or interpret Core law.

## What Veridia is

- The patient health identity Stage inside HealthOS.
- The place where the patient interacts with mediated key custody controls exposed through Core and the Apple substrate (Secure Enclave / Keychain).
- The place where consent visibility, access trail visibility, owned-data visibility, export controls, and patient agent interaction are presented.
- The app-facing shell for patient agent interaction over the User-Agent Runtime.
- A Core-mediated Stage/interface, not a law-bearing layer.

## What Veridia is not

- Not Core law or a Core layer.
- Not the owner of consent, habilitation, finality, gate, provenance, or storage law.
- Not the User-Agent Runtime itself.
- Not a professional clinical workspace.
- Not a service-operations dashboard.
- Not a clinical authority.
- Not a key authority independent of Core and the Apple substrate (Secure Enclave / Keychain) custody.
- Not a storage authority.

Key custody wording: Veridia presents Core-backed key and access controls. Core and the Apple substrate remain the authority for actual secure custody mechanics.

## Primary flows

1. **Health identity overview** — the patient views their HealthOS identity, linked services, and access state.
2. **Mediated key custody controls** — the patient interacts with key and access controls as presented by Core.
3. **Owned data overview** — the patient views data categories, visibility, and retention state.
4. **Consent visibility and allowed consent actions** — the patient views active, revoked, and expiring consents; initiates allowed consent actions through Core.
5. **Access audit trail** — the patient views a governed access log of who accessed their data, when, and under what authority.
6. **Export requests and export status** — the patient requests data exports and views export status.
7. **Patient agent interaction** — the patient interacts with the patient agent through the User-Agent Runtime surface.

## Primary screens

| Screen | Purpose |
|---|---|
| Identity | Health identity overview and linked service state |
| Keys and access | Mediated key custody controls and access state |
| My data | Owned data categories, visibility, retention status |
| Consent center | Consent visibility and allowed consent actions |
| Access trail | Governed access audit log |
| Exports | Export requests and status |
| Patient agent | Patient agent interaction surface |

## Key UI states

All states are scaffold-only. No final UI shell is implemented.

| State | Description |
|---|---|
| `identity-loaded` | Patient identity is resolved and mediated identity state is displayed |
| `consent-list-loaded` | Active, revoked, and expiring-soon consents are shown |
| `audit-log-loaded` | Access events are shown with redaction status and emergency markers |
| `export-pending` | Export request is submitted and awaiting processing |
| `export-ready` | Export is available for download |
| `user-agent-ready` | Patient agent session is open and interaction is available |
| `degraded` | Core-mediated surface is unavailable; fail-closed state displayed |

## Important user flows

All flows are governed through Core-mediated surfaces. Veridia does not initiate clinical acts, modify storage law, or bypass consent/gate/provenance mechanisms.

- **Consent revocation flow**: patient initiates revocation request → Core validates lawfulness → Core records revocation → Veridia displays updated state.
- **Export request flow**: patient requests export → Core evaluates export policy → Core initiates export job → Veridia displays status.
- **Audit review flow**: patient queries access trail → Core mediates redacted event view → Veridia displays events with redaction status.
- **Patient agent flow**: patient sends query → User-Agent Runtime processes under lawfulContext → response is informational-user-facing only → Veridia displays result.

## Related detailed contracts

- `docs/architecture/24-veridia-screen-contracts.md` — screen-level contracts and action/result shapes.
- `docs/architecture/48-native-macos-ui-design-system-and-app-shells.md` — visual design and shell architecture.
- `swift/Sources/HealthOSCore/UserSovereigntyContracts.swift` — Swift governance contracts for Veridia surfaces.
- `schemas/contracts/user-agent-patient-identity-veridia.schema.json` — JSON Schema for Veridia patient identity contracts.

## Boundaries

| Boundary | Rule |
|---|---|
| Core sovereignty | Veridia invokes and displays Core-mediated state. Veridia does not become Core. |
| GOS | Veridia may consume GOS-mediated app surfaces; does not interpret operational policy independently. |
| User-Agent Runtime | User-Agent Runtime remains the runtime. Veridia is the app shell that hosts patient agent interaction. |
| Storage | Veridia does not access raw storage internals, reidentification mapping, or direct identifiers by default. |
| Clinical acts | Veridia cannot initiate clinical acts, prescriptions, referrals, or record finalization. |
| Key custody | Veridia presents Core-backed key controls. Core and the Apple substrate own key custody authority. |

## Scaffold posture / non-claims

- Scaffold placeholder only. No final UI shell is implemented.
- No patient agent runtime wiring is active at scaffold maturity.
- No cryptographic key operations are implemented in this target.
- No LGPD/regulatory compliance is established by this scaffold.
- No production readiness is claimed.
- Swift target: `HealthOSVeridiaApp` — executable scaffold placeholder.
- Smoke command: `make smoke-veridia` / `cd swift && swift run HealthOSVeridiaApp --smoke-test`
- The current smoke-testable session boundary is valid proof of Boundary scaffold, not a reason to add unrelated Stage wiring before its upstream mediated surfaces are implemented and stable.

Future Veridia wiring must follow `docs/architecture/50-app-layer-boundary-and-reference-apps.md`: the consumed mediated surface must be implemented and stable, and the Veridia Custom must cover the new surface.
