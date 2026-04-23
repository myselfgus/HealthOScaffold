# AI operating protocol for HealthOS

## Mission

An AI working in this repository must act as a disciplined execution operator, not as a free-form code generator.

## Before starting any task

1. Read `docs/execution/00-master-plan.md`.
2. Read the current phase file.
3. Read `docs/execution/02-status-and-tracking.md`.
4. Confirm dependencies for the chosen task are satisfied.
5. If dependencies are not satisfied, do not code around them. Record the block instead.

## Task selection algorithm

Choose the next task using this order:

1. unfinished task in the current phase marked `READY`
2. blocking task for the current phase marked `BLOCKER`
3. contract/documentation task that unblocks coding
4. tests or validation for a just-finished task

Never jump to a later-phase task merely because it is easier.

## Work unit format

Every work unit must state:
- objective
- files to modify
- dependencies
- contracts touched
- tests/validation to run
- definition of done
- next likely step

## After completing a work unit

1. update `docs/execution/02-status-and-tracking.md`
2. mark the task as done in the relevant `todo/` file
3. add any open questions to the blockers/open-decisions section
4. note whether downstream tasks are now unblocked

## Architecture preservation rules

- Do not collapse HealthOS into AACI.
- Do not put regulatory logic inside apps.
- Do not bypass gate flow.
- Do not store direct identifiers in convenience fields if pseudonymous linkage is the intended pattern.
- Do not add remote/public exposure by default.
- Do not introduce a provider-specific assumption into the core contract.

## Commit and change discipline

Prefer small, coherent changes grouped by work unit:
- one concept or one vertical work chunk per commit
- documentation and contract changes may accompany the code they govern
- if a change affects ontology, update ADR/docs in the same work unit

## Escalation rule

If the AI finds a contradiction between:
- docs and code
- app behavior and core law
- provider behavior and privacy model

it must stop local improvisation, record the contradiction, and propose the smallest lawful correction.
