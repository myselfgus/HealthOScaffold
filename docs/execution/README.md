# Execution layer

This directory turns the scaffold into a governed execution system.

Use it in this order:

1. `00-master-plan.md`
2. `01-agent-operating-protocol.md`
3. `02-status-and-tracking.md`
4. `phases/phase-00-governance.md`
5. continue sequentially through phase files
6. consult `todo/` files for executable domain work

## Purpose

This layer exists so that:
- humans do not lose the conceptual hierarchy
- AIs do not jump randomly between layers
- every task has dependencies, outputs, tests, and a definition of done
- progress can be resumed without ambiguity

## Rules

- Never skip a phase dependency without recording the decision.
- Never implement app behavior before the relevant core contract exists.
- Never implement a gate-bypassing shortcut.
- Never treat AACI as the whole system.
- Always update status files after a completed work chunk.
