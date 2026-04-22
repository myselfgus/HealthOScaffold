# Data layers

HealthOS is not zero-knowledge against itself.

## 1. Direct Identifiers Layer
Contains:
- CPF
- full name
- date of birth
- contact identifiers
- document identifiers

Protection:
- encrypted at rest
- strict access logging
- tokenized/hash indexes where possible

## 2. Clinical / Operational Content Layer
Contains:
- notes
- transcripts
- operational records
- drafts
- context summaries
- service-bound artifacts

Protection:
- encrypted at rest
- processable by HealthOS
- separated from direct identifiers

## 3. Access & Governance Metadata Layer
Contains:
- consent
- purpose/finality
- policy
- habilitation
- device/session metadata
- access decisions

## 4. Derived AI Artifacts Layer
Contains:
- summaries
- embeddings metadata
- extracted tasks
- classification outputs
- draft structures

## 5. Reidentification Mapping Layer
Contains:
- link between pseudonymous subject IDs and real civil identifiers
- access requires governed re-identification flow
- every re-identification is audited
