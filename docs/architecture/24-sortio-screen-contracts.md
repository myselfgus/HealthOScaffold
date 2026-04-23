# Sortio screen contracts

## Dashboard
Primary actions:
- inspect owned-data overview
- inspect recent activity
Contract calls:
- bounded user-owned summary retrieval
Result states:
- ready
- restricted
- failed

## My data / categories
Primary actions:
- browse categories
- inspect item metadata or bounded content
Contract calls:
- user-scoped artifact/data listing and reads
Result states:
- ready
- redacted
- denied
- failed

## Consent center
Primary actions:
- inspect consent objects
- grant/restrict/revoke where allowed
Contract calls:
- consent read/update requests
Result states:
- active
- restricted
- expired
- revoked
- updating
- failed

## Access trail
Primary actions:
- inspect bounded audit history
- apply filters
Contract calls:
- audit trail reads under user scope
Result states:
- ready
- filtered
- redacted
- failed

## Exports
Primary actions:
- request export
- inspect export status
Contract calls:
- export request / status retrieval
Result states:
- pending
- ready
- failed

## User-agent panel
Primary actions:
- ask for explanation/summarization within own scope
Contract calls:
- user-agent runtime invocation
Result states:
- available
- degraded
- paused
- failed
