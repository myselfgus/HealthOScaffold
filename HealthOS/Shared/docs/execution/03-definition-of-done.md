# Definition of done

## A documentation task is done when
- the document names exact boundaries
- dependencies are explicit
- terms match canonical architecture language
- downstream implementers can act without guessing

## A schema task is done when
- the entity/contract exists as machine-readable schema
- required fields are explicit
- status/state enums are explicit where relevant
- the schema matches docs and code contracts

## A core contract task is done when
- inputs, outputs, invariants, and failure conditions are named
- no app-specific assumptions leak into the core
- consent, habilitation, provenance, and gate semantics remain preservable

## A runtime task is done when
- lifecycle states are defined
- actor/agent boundaries are explicit
- communication paths are named
- error and termination behavior are not implicit

## An app task is done when
- screens/states/flows are mapped
- the app consumes rather than defines core law
- user role and service context are explicit

## An ops task is done when
- bootstrap steps are reproducible
- logs/health checks/backup expectations are stated
- exposed surfaces are explicit
- private/default posture is preserved

## A phase is done when
- all READY tasks in the phase are complete
- blocker decisions are either resolved or consciously deferred with recorded impact
- downstream phase inputs are available
