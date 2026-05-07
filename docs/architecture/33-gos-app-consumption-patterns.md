# GOS app consumption patterns

## Purpose

Define what Stages are allowed to consume from GOS-driven runtime work without becoming sovereign interpreters of GOS.

This applies to initial Stages and future Stages. Stage consumption patterns are not a closed ontology of HealthOS.

## Core rule

Stages do not load compiled GOS bundles as their source of law.
Stages consume runtime-mediated state derived from GOS execution.
Substantial Stage wiring also requires the relevant mediated surface to be implemented and stable, plus a complete Custom.

This preserves the correct split:
- HealthOS Core governs law
- GOS structures operational work
- runtimes execute within that structure
- Stages present bounded results and states

## Allowed Stage consumption categories

Stages may consume runtime-mediated outputs such as:
- stage/status indicators
- degraded-state indicators
- retrieval summaries
- draft previews
- gate-needed indicators
- deadline/escalation surfaces
- provenance-facing summaries
- human-review summaries

Stages may not consume GOS in order to independently decide:
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

## Veridia patterns

Veridia may show:
- what categories of runtime activity touched the user data
- provenance summaries of why a draft/retrieval happened
- what gates/human review states exist around outputs related to the user
- what service/runtime contexts operated under lawful access

Veridia may not:
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

Stages should present GOS-derived runtime information as:
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
