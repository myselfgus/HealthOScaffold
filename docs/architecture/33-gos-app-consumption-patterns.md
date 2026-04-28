# GOS app consumption patterns

## Purpose

Define what apps are allowed to consume from GOS-driven runtime work without becoming sovereign interpreters of GOS.

## Core rule

Apps do not load compiled GOS bundles as their source of law.
Apps consume runtime-mediated state derived from GOS execution.

This preserves the correct split:
- HealthOS Core governs law
- GOS structures operational work
- runtimes execute within that structure
- apps present bounded results and states

## Allowed app consumption categories

Apps may consume runtime-mediated outputs such as:
- stage/status indicators
- degraded-state indicators
- retrieval summaries
- draft previews
- gate-needed indicators
- deadline/escalation surfaces
- provenance-facing summaries
- human-review summaries

Apps may not consume GOS in order to independently decide:
- whether lawful access exists
- whether a health act is effective
- whether a gate can be bypassed
- whether finality, consent, or habilitation are satisfied

## Scribe patterns

Scribe may show:
- active workflow stage
- active GOS bundle/workflow identity as runtime audit context
- actors and primitive families bound by the AACI resolved runtime view
- bounded reasoning summaries and provenance operations for mediated SOAP/referral/prescription draft paths
- what the runtime is trying to extract or prepare
- degraded transcription/retrieval state
- draft previews prepared under GOS-driven runtime work
- deadline/escalation hints surfaced by runtime
- gate-required state for draft outputs

Scribe may not:
- parse GOS and decide that a document no longer needs human gate
- infer consent or habilitation from GOS declarations alone
- effectuate a document merely because the GOS spec prepared it
- expose raw compiled spec or runtime-binding JSON as app-facing policy input

## Sortio patterns

Sortio may show:
- what categories of runtime activity touched the user data
- provenance summaries of why a draft/retrieval happened
- what gates/human review states exist around outputs related to the user
- what service/runtime contexts operated under lawful access

Sortio may not:
- reinterpret GOS as a substitute for the platform's consent/governance records
- independently approve operational outputs

## CloudClinic patterns

CloudClinic may show:
- service-level operational stages
- pending runtime-driven tasks
- deadline/escalation state
- draft queue summaries
- operational bottlenecks surfaced by runtime work

CloudClinic may not:
- turn GOS into a standalone workflow engine outside HealthOS core/runtime seams
- independently decide effectuation of regulated outputs

## Recommended UI posture

Apps should present GOS-derived runtime information as:
- mediated
- bounded
- reviewable
- provenance-capable
- subordinate to core law

Good phrasing examples:
- "Runtime prepared draft under governed workflow"
- "Human review required before effectuation"
- "Degraded operational context"
- "Escalation suggested by runtime guard"

Bad phrasing examples:
- "Protocol approved this action"
- "App verified legal access"
- "This is final because workflow says so"

## Consequence

Apps remain ergonomic surfaces.
They never become the constitutional interpreter of GOS.
