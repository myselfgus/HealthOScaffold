# Provider threshold policy

## Purpose

Turn benchmark dimensions into explicit accept/reject guidance by task class.

## Rule

Thresholds are directional governance rules for scaffold and early implementation.
They may be tightened later, but should already guide selection decisions now.

## Class A — identity-sensitive / high-privacy live tasks
Examples:
- live transcription
- active-session context assembly
- draft preparation from sensitive session material

Threshold posture:
- privacy: highest priority
- latency: must support live use without major interruption
- fallback tolerance: low
- remote use: only when explicitly policy-allowed

Decision guidance:
- reject providers that require routine remote use when a viable local option exists
- reject providers with unstable degraded behavior in live use
- accept slightly lower qualitative performance if privacy and stability are materially better

## Class B — bounded organizational tasks
Examples:
- note organization
- task extraction
- formatting/cleanup

Threshold posture:
- privacy: high priority
- latency: moderate priority
- fallback tolerance: moderate
- remote use: allowed under policy when privacy posture is acceptable

Decision guidance:
- accept remote fallback when outputs remain drafts or derived assistance
- prefer providers with predictable formatting/organization quality over marginal latency wins

## Class C — heavy offline/deferred work
Examples:
- benchmarking
- retrospective summarization
- adapter evaluation

Threshold posture:
- privacy: governed by dataset posture
- latency: low priority
- cost/throughput: higher priority
- remote use: acceptable when dataset policy permits

Decision guidance:
- prioritize evaluation rigor, throughput, and governance traceability
- reject datasets/providers lacking clear lineage or de-identification posture

## Threshold review questions
- does this provider fit the task class privacy posture?
- does degraded behavior remain acceptable for the class?
- is fallback behavior explainable and provenance-visible?
- does this choice preserve draft/gate semantics where relevant?
