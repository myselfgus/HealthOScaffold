# CloudClinic screen contracts

## Dashboard
Primary actions:
- inspect service load
- inspect runtime/queue health
Contract calls:
- service-scoped operational summaries
Result states:
- ready
- saturated
- deferred
- failed

## Patient registry
Primary actions:
- browse/search service-scoped patients
- open patient operational view
Contract calls:
- service-scoped patient lookup
Result states:
- ready
- no match
- denied
- failed

## Queue board
Primary actions:
- inspect pending work
- route/reassign bounded operational items
Contract calls:
- queue reads and queue-action requests under service scope
Result states:
- ready
- saturated
- deferred
- failed

## Pending drafts
Primary actions:
- inspect draft backlog
- open draft metadata and route to professional review
Contract calls:
- service-scoped draft metadata listing
Result states:
- ready
- awaiting_gate
- failed

## Pending gates
Primary actions:
- inspect gate backlog
- route to appropriate resolver
Contract calls:
- gate listing / assignment visibility
Result states:
- pending
- reviewing
- resolved
- failed

## Service documents / operational records
Primary actions:
- inspect service-owned operational records under lawful scope
Contract calls:
- service-scoped artifact/document reads
Result states:
- ready
- partially redacted
- denied
- failed

## Staff activity / coordination view
Primary actions:
- inspect high-level operational activity
Contract calls:
- service-scoped operational summaries and audit slices
Result states:
- ready
- filtered
- failed
