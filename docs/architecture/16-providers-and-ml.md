# Providers and ML

## Provider classes
- LanguageModelProvider
- SpeechToTextProvider
- EmbeddingProvider
- RetrievalProvider
- FineTuningProvider

## Principles
- provider choice is task-dependent
- local/private-first where quality permits
- remote fallback only via explicit policy
- provider routing belongs to AACI/runtime orchestration, not to app UIs
- provider routing must not rewrite governance invariants

## Task-class routing baseline

### Class A — identity-sensitive or high-privacy tasks
Examples:
- live transcription
- active-session context assembly
- draft preparation from sensitive session material

Routing policy:
- prefer local/private-first providers
- remote fallback only if explicitly enabled by policy and task class
- remote fallback must be provenance-visible

### Class B — bounded organizational tasks
Examples:
- note organization
- task extraction
- document formatting

Routing policy:
- local-first preferred
- remote fallback allowed under policy when privacy/risk posture permits
- outputs must remain drafts or derived assistance, never effective acts

### Class C — heavy offline/deferred work
Examples:
- evaluation
- retrospective summarization
- adapter testing
- benchmarking

Routing policy:
- may use offline or remote resources under governed dataset policy
- must remain outside live-session critical path

## Routing dimensions

Every provider decision should consider:
- privacy mode
- latency target
- task criticality
- model/task fit
- operator policy
- current runtime pressure/degraded mode

## Policy outcomes
- local_required
- local_preferred
- local_or_remote
- remote_allowed_if_deidentified
- offline_only

## Benchmark matrix dimensions
- latency
- qualitative task fitness
- privacy posture
- memory/compute footprint
- failure rate
- degraded-mode behavior

## Model registry lifecycle
- candidate
- evaluated
- approved
- active
- deprecated
- retired

## Offline ML boundary
Python remains the offline ML boundary for:
- datasets
- evaluation
- adapter jobs
- promotion/rollback logic

## Open tasks
- define adapter promotion path in more procedural detail
- define dataset governance and de-identification policy for training
- define benchmark harness artifacts and score thresholds
