# Apple sovereignty architecture

## Canonical statement

HealthOS treats Apple-controlled hardware, operating system primitives, filesystem protections, and Apple-controlled inference surfaces as the preferred sovereign substrate for clinical data and engineering work. This is a permanent architectural choice rooted in an explicit thesis: sovereignty is more reliably achieved when the substrate itself is controlled by a single, accountable party with hardened security posture, rather than assembled from multi-vendor configuration layers. The choice is not deployment preference and does not imply production readiness by itself. It is a foundational constraint that shapes storage design, compute policy, and engineering-agent posture across HealthOS.

## Why sovereignty is a hardware property, not a configuration

Mainstream healthcare deployments frequently delegate data sovereignty to:

- enterprise cloud configuration managed by a third-party vendor
- customer compliance posture maintained through policy documents and audits
- managed database services where encryption and key custody are vendor-controlled
- contractual controls that specify sovereignty but do not enforce it at the substrate level

Each delegation layer adds an external trust domain. Compliance becomes an assertion about configuration rather than an observable property of the substrate.

HealthOS positions sovereignty as an emergent property of substrate choice combined with HealthOS Core governance.

- Hardware and OS trust reduces the number of external trust domains that must be verified and maintained.
- Key custody closer to local hardware shrinks the attack surface available to cloud-side actors.
- Local filesystem protections with OS-enforced encryption reduce reliance on vendor-managed key rotation.

This does not eliminate all risk. Supply-chain risk, firmware vulnerabilities, and local physical access remain real threat surfaces. The claim is directional: Apple-first substrate reduces, but does not zero out, external trust dependencies.

## The trust chain

The intended trust chain for HealthOS data and inference:

```text
iPhone / iPad patient and professional surfaces
  └─ Apple device security and local key custody
    └─ Mac mini / Mac Studio HealthOS hosts
      └─ APFS + FileVault + Secure Enclave key custody
        └─ HealthOS Core lawfulContext and storage invariants (Inv 14/15)
          └─ Apple Private Cloud Compute (preferred target when local inference is insufficient)
```

Notes on this chain:

- Apple devices do not all have identical Secure Enclave implementations across hardware generations. The trust chain relies on the same family of Apple-controlled trust primitives, not identical behavior across all devices.
- Apple Private Cloud Compute is the preferred sovereignty-preserving remote inference plane when local Apple Silicon compute is insufficient. PCC is a target architecture in this document; it is not currently integrated in HealthOS and must not be claimed as delivered capability.
- Non-Apple remote inference providers are not excluded by this architecture, but they require explicit policy, degraded-sovereignty classification, provenance markers, and anti-fake constraints per Inv 17/22.

## The three planes of sovereignty

### Data plane

The data plane defines how HealthOS records are stored and protected.

Primitives:
- APFS filesystem
- FileVault full-volume encryption with Secure Enclave key custody
- file-backed records as canonical storage substrate
- `lawfulContext` validation enforced on every read and write at the storage layer (Inv 14)
- storage layer separation enforcing sensitivity semantics per layer (Inv 15)
- `FileBackedStorageService` and related storage law as the primary implemented seam

File-backed storage with `lawfulContext` validation is permanent canonical record design. It is not a transitional approach pending a database migration. SQL and object-store backends may complement file-backed storage, but they do not replace it as the canonical record substrate.

SQL and object backends may still inherit Apple-rooted storage protection when persisted on APFS/FileVault volumes. The architectural constraint is not that SQL is inherently non-sovereign. The constraint is that SQL/object layers must not become canonical record custody unless they preserve HealthOS layer semantics and `lawfulContext` enforcement end-to-end. See also: filesystem-as-record section below.

### Compute plane

The compute plane defines where inference and computation execute.

Policy:
- local Apple Silicon first
- Apple Private Cloud Compute is the preferred sovereignty-preserving remote inference plane when local compute is insufficient (target architecture; not yet integrated)
- non-Apple remote providers require explicit operator policy, degraded-sovereignty classification, provenance markers, and anti-fake posture per Inv 17/22
- provider routing must remain fail-closed: no remote provider receives sensitive data without explicit policy (Inv 17)

### Governance plane

The governance plane is the constitutional layer that makes data and compute sovereign in the HealthOS sense.

Primitives:
- HealthOS Core invariants (Inv 1)
- identity and habilitation contracts
- consent and finality law
- gate requirement: regulatory effectuation requires human approval
- provenance and audit records
- storage law (Inv 14/15)

This plane is the sovereign layer. Substrate and compute choices reduce external trust dependencies; the governance plane enforces HealthOS law over whatever substrate and compute are in use.

The governance plane is HealthOS-controlled. It is not delegated to Apple, to a cloud vendor, or to the engineering-agent layer.

## Why filesystem-as-record is the right abstraction here

The framing that filesystem-as-record is "temporary until a database is built" is incorrect.

The filesystem-as-record design reflects a deliberate set of constraints:

- APFS with FileVault gives the canonical record storage Apple-rooted encryption and key custody at rest without requiring a separately managed database encryption layer.
- File-backed records with explicit `lawfulContext` validation enforce Core law at the point of every read and write, including direct-identifier and reidentification-mapping layers (Inv 14/15).
- File paths and directory structures provide a transparent, auditable, durable record location that survives database migration, ORM version drift, and schema evolution independently.

SQL and object-store backends are complementary substrates:

- They are appropriate for query, index, projection, and reporting workloads where structured query capability matters.
- They may inherit Apple-rooted storage protection when persisted on APFS/FileVault.
- They must never replace file-backed storage as the canonical record unless they fully preserve layer semantics and `lawfulContext` enforcement.

GAP-003 in `docs/execution/14-final-gap-register.md` should be read in this light: the gap is not that SQL/object backends need to reach parity with file-backed storage as a canonical record substrate. The gap is that complementary SQL/object adapters for query/index/projection workloads must preserve `lawfulContext` and layer semantics when they are eventually built.

`FileBackedStorageService` and the storage invariants (Inv 14/15) where already implemented represent tested operational path maturity for this design within first-slice scope.

## Implications for downstream architecture

The Apple sovereignty thesis produces explicit downstream constraints.

**GAP-003 reframe.** SQL/object backends are complementary query/index/projection substrates, not parity replacements for file-backed canonical storage. Future SQL/object adapters must preserve `lawfulContext` and layer semantics. See `docs/execution/14-final-gap-register.md`.

**Steward for Xcode posture.** Doc 45 (`docs/architecture/45-healthos-xcode-agent.md`) defines Steward for Xcode. Steward for Xcode integrates with Xcode Intelligence as an Apple-controlled engineering runtime surface, while HealthOS contributes instructions, `healthos-mcp`, derived repository memory, and deterministic CLI operations. This follows directly from the Apple-first engineering posture: Apple's native workspace intelligence belongs to the same sovereign substrate family. HealthOS does not duplicate what Xcode provides natively.

**Provider and ML integration.** Remote inference providers outside the Apple sovereignty chain require explicit operator policy, degraded-sovereignty classification, provenance markers, and anti-fake constraints. This applies to all non-Apple inference surfaces including external LLM and STT providers currently at stub/scaffold maturity.

**Cross-device coordination.** Cross-device sync, if ever implemented, should prefer Apple-native primitives only where their documented encryption and account-trust properties match the HealthOS layer being synchronized. CloudKit, if ever used, is a transport/projection/sync candidate, not canonical record custody, unless explicitly governed by Core invariants and layer policy.

**Deterministic CLI.** The deterministic CLI remains necessary for CI and non-Xcode automation regardless of Xcode Intelligence integration maturity. It is not a fallback; it is a distinct automation surface.

## Non-claims

This document does not claim:

- Apple is infallible or that Apple supply-chain risk does not exist.
- Apple Private Cloud Compute is currently integrated with HealthOS.
- Xcode Intelligence integration is currently implemented in HealthOS.
- MCP server integration is currently implemented in HealthOS.
- regulatory certification or compliance of any kind.
- production readiness of any HealthOS component.
- filesystem-backed storage alone provides legal compliance.
- SQL and object-store backends are forbidden from HealthOS.
- non-Apple remote providers can never be used under any policy.
- HealthOS Core law is delegated to Apple or to any Apple service.

Legal and compliance posture comes from HealthOS Core governance combined with operational and regulatory implementation. Substrate choice reduces external trust dependencies but does not substitute for Core law, consent, habilitation, gate, and provenance contracts.

## Relationship to other documents

- `docs/architecture/01-overview.md` — canonical hierarchy and HealthOS constitutional placement
- `docs/architecture/05-data-layers.md` — storage layer definitions and sensitivity taxonomy
- `docs/architecture/07-storage-and-sql.md` — storage architecture and SQL/file relationship
- `docs/architecture/45-healthos-xcode-agent.md` — Steward for Xcode: Xcode Intelligence as native runtime surface for Steward, following from Apple-first engineering posture
- `docs/execution/10-invariant-matrix.md` — Inv 14 (lawfulContext enforcement), Inv 15 (storage layer sensitivity), Inv 17/22 (provider honesty and anti-fake posture)
- `docs/execution/14-final-gap-register.md` — GAP-003: SQL/object complementary backend, reframed per this document

## Maturity

This document is maturity level **doctrine-only**.

The thesis is partly reflected in existing tested file-backed storage paths (`FileBackedStorageService`, storage invariant enforcement, first-slice lawfulContext wiring), which are at tested operational path maturity within their implemented scope. The thesis as a unified architectural statement is doctrinal.

Specific component maturity:

- File-backed storage with `lawfulContext`: tested operational path (first-slice scope); broader propagation remains open (Inv 14/15).
- Apple Silicon host posture and APFS/FileVault usage: implemented operational baseline for this repository.
- Apple Private Cloud Compute integration: doctrine-only. Must not be claimed above doctrine-only until end-to-end verification.
- Xcode Intelligence integration: doctrine-only or scaffolded contract depending on verified repository state; see doc 45.
- MCP server: doctrine-only; see doc 45 and doc 17.

Storage invariants may be more mature than this doctrinal articulation of the thesis that unifies them. Inv 43 applies: scaffold or foundation phase closure is not production readiness.
