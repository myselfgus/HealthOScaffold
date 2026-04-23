# Data layers

HealthOS is not zero-knowledge against itself.
HealthOS is health-exclusive by ontology.

This layering exists to make privacy and governance architectural properties, not decorative app behavior.

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
- strict separation from routine clinical-operational processing

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
- processable by HealthOS core and runtimes under lawful context
- separated from direct identifiers through pseudonymous linkage

## 3. Access & Governance Metadata Layer
Contains:
- consent with clinical purpose/finality
- policy
- habilitation
- gate requests/resolutions
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

## Patient sovereignty framing

Patient sovereignty is implemented as governance power, not as mandatory physical custody of all bytes.
The patient governs:
- access authorization scope
- visibility boundaries
- revocation posture where lawful
- export pathways

HealthOS remains the operational custodian of infrastructure and canonical persistence.

## Access posture

- access is always online within the private mesh posture
- no offline operational mode is part of HealthOS doctrine
- lawfulContext is the access passport across layers
