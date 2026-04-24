# GOS runtime binding

## Purpose

Define how Governed Operational Spec (GOS) binds into HealthOS runtimes without becoming a second constitution.

## Binding rule

Runtimes may bind to GOS.
Runtimes do not become sovereign because they bind to GOS.
Core law remains above runtime binding.

## Primary consumer

AACI is the primary early consumer of GOS.

Future consumers may include:
- async runtime
- user-agent runtime
- service-specific operational runtimes

## Binding layers

### 1. spec loading
Runtime receives a compiled GOS bundle.

Responsibilities:
- load the canonical JSON form
- load compiler report and source provenance hints
- fail closed if the bundle is invalid or inactive

The scaffold now includes typed Swift seams for this layer:
- `GOSBundleLoader`
- `GOSBundleRegistry`
- `GOSLoadRequest`
- `GOSCompiledBundle`
- `GOSRuntimeBindingPlan`
- `GOSPrimitiveBinding`

A minimal file-backed registry/loader also now exists as `FileBackedGOSBundleRegistry`.
It is intentionally minimal, but it is no longer only doctrinal.

### 2. runtime precheck
Before using GOS, runtime performs prechecks.

Prechecks should confirm:
- bundle is structurally valid
- bundle status is active/reviewed as required by local policy
- required primitive families are present for the intended runtime path

The scaffold now includes an executable AACI-side activation seam:
- `AACIOrchestrator.activateGOS(specId:loader:)`

That activation step:
- loads the active bundle for a spec id
- reads bundle lifecycle state
- selects bundle-provided runtime binding plan when present
- falls back to the AACI default binding plan when bundle-local binding is absent
- derives a small resolved runtime view from the active bundle and binding plan
- returns an activation summary instead of silently hiding binding state

### 3. lawful-context boundary
Before any GOS-driven work touches sensitive state, the runtime must still satisfy core lawful access checks.

GOS may declare scope requirements.
GOS may not satisfy those requirements by declaration alone.

This means:
- GOS can say a consent-scoped action is expected
- only HealthOS Core can validate that consent basis actually exists

### 4. subagent routing
AACI may route subagents based on GOS primitives.

Examples:
- signal specs guide capture/transcription intake
- slot specs guide extraction targets
- derivation specs guide bounded computed fields
- task specs guide extraction/retrieval/composition steps
- draft output specs guide what draft artifacts may be prepared
- guard specs guide degraded/escalation behavior
- deadline specs guide timers and timing surfaces
- evidence hook specs guide provenance/audit collection
- human gate requirement specs guide draft-only vs effectable boundaries

## Current executable AACI posture

The scaffold now uses the resolved runtime view as a small adaptation layer between the active bundle and AACI execution.

That means:
- AACI does not pass raw compiled GOS JSON through orchestration paths
- AACI does not interpret GOS as arbitrary executable code
- the runtime consumes only the bundle identity, workflow title, actor bindings, primitive-family bindings, and bounded reasoning summary needed for the current path

In the current first-slice executable path, that resolved runtime view now mediates:
- capture event/state metadata
- transcription metadata and explicit `gos.use.transcription` provenance
- context retrieval metadata and explicit `gos.use.context.retrieve` provenance
- SOAP draft composition
- referral draft derivation
- prescription draft derivation

### 5. runtime-state surfacing
Runtimes should surface GOS-driven state to apps only through runtime-state surfaces.

Apps may learn:
- what stage is in progress
- what degraded state occurred
- what guard or deadline surfaced
- what draft output is ready for review
- what human gate is required

Apps should not become direct interpreters of compiled GOS bundles as the source of law.

## Initial AACI binding map

The scaffold now contains this map both doctrinally and in Swift form through `AACIGOSBindings.defaultBindingPlan(specId:)`.

### CaptureAgent
Consumes:
- signal specs
- slot specs
- evidence hook specs

### TranscriptionAgent
Consumes:
- signal specs
- task specs
- guard specs
- evidence hook specs

### IntentionAgent
Consumes:
- slot specs
- derivation specs
- task specs

### ContextRetrievalAgent
Consumes:
- slot specs
- derivation specs
- task specs
- guard specs
- scope requirement specs
- evidence hook specs

### DraftComposerAgent
Consumes:
- slot specs
- derivation specs
- task specs
- draft output specs
- human gate requirement specs
- evidence hook specs

### TaskExtractionAgent
Consumes:
- slot specs
- task specs
- deadline specs
- escalation specs
- evidence hook specs

### ReferralDraftAgent / PrescriptionDraftAgent
Consumes:
- slot specs
- derivation specs
- task specs
- draft output specs
- human gate requirement specs
- evidence hook specs

### NoteOrganizerAgent
Consumes:
- slot specs
- task specs
- draft output specs

### RecordLocatorAgent
Consumes:
- task specs
- scope requirement specs
- evidence hook specs

## Runtime binding non-goals

Runtime binding does not mean:
- compiled GOS is executed as arbitrary code
- apps can bypass runtime law by providing their own GOS
- GOS can produce effective clinical acts without gate and core law
- runtime-specific vendor bindings become part of the GOS constitution

## Remaining work

Still needed after this binding wave:
- broader adoption beyond the current first-slice runtime paths
- richer runtime validation hooks outside the current binding-plan and bundle-integrity checks
- version pinning rules
- app-surface policy for which GOS-derived facts may be exposed
