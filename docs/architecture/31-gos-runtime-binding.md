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

### 2. runtime precheck
Before using GOS, runtime performs prechecks.

Prechecks should confirm:
- bundle is structurally valid
- bundle status is active/reviewed as required by local policy
- required primitive families are present for the intended runtime path

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

## Runtime binding non-goals

Runtime binding does not mean:
- compiled GOS is executed as arbitrary code
- apps can bypass runtime law by providing their own GOS
- GOS can produce effective clinical acts without gate and core law
- runtime-specific vendor bindings become part of the GOS constitution

## Future work

Still needed after this binding doctrine:
- explicit loader contracts
- activation/deprecation lifecycle
- version pinning rules
- compiled-bundle storage/versioning rules
- runtime validation hooks
- app-surface policy for which GOS-derived facts may be exposed
