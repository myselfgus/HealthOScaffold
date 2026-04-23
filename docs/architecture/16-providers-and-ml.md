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

## Threshold policy
Detailed threshold guidance by task class lives in:
- `docs/architecture/27-provider-threshold-policy.md`

## Benchmark harness artifacts
Each benchmark run should produce:
- model/provider identifier
- task class
- dataset/eval set reference
- latency summary
- failure summary
- qualitative note or rubric output
- privacy mode used
- decision recommendation

## Model registry lifecycle
- candidate
- evaluated
- approved
- active
- deprecated
- retired

## Adapter promotion path
1. candidate adapter created
2. offline evaluation run recorded
3. governance review of dataset lineage and de-identification posture
4. approval decision recorded
5. adapter promoted to active for bounded task class
6. rollback path recorded before widespread use

## Dataset governance
- dataset source must be recorded
- de-identification posture must be recorded
- purpose of dataset must be recorded
- sensitive live-session data must not enter tuning flow without explicit governed pathway
- evaluation sets should be separated from training sets

## Rollback rule
A promoted adapter/model must have:
- previous known-good fallback
- rollback trigger conditions
- provenance-visible demotion when retired from active use

## Offline ML boundary
Python remains the offline ML boundary for:
- datasets
- evaluation
- adapter jobs
- promotion/rollback logic

## Open tasks
- define operator review checklist for promotion decisions
