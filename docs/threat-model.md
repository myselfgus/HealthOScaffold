# Threat model (initial)

## Primary risks
- leakage of direct identifiers
- unauthorized re-identification
- inappropriate service-to-patient cross-access
- gate bypass
- provenance tampering
- local machine compromise
- backup leakage
- model provider misuse
- training data contamination

## Primary mitigations
- separated data layers
- append-only provenance table and audit log
- explicit purpose/finality checks
- habilitation time windows
- per-service isolation
- encrypted backups
- provider routing policy
- offline ML pipeline boundary
- mesh-only administrative access
