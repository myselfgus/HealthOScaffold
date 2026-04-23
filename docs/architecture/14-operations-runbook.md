# Operations runbook

## Single-node baseline
- bootstrap local tree
- provision PostgreSQL
- configure launchd entries
- verify local ports
- verify logs
- verify backup destination and restore process

## Daily checks
- runtime health
- failed jobs
- gate backlog
- backup freshness
- storage growth

## Change discipline
- prefer staged upgrades
- review migrations before applying
- keep restore drills documented
