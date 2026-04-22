# HealthOS canonical overview

## What HealthOS is

HealthOS is the full sovereign computational environment for health operations.

It contains:
- storage/drive/cloud behavior
- governance and access rules
- identity and habilitation
- provenance and versioning
- runtimes
- actors and agents
- apps and interfaces

It is not reducible to:
- an app
- a cloud drive
- an agent framework
- an EHR
- AACI alone

## What AACI is

AACI is one runtime of HealthOS.

AACI = Ambient-Agentic Clinical Intelligence.

It exists to automate bureaucratic and operational work that happens during or around health work:
- transcription
- contextual retrieval
- draft composition
- note structuring
- task extraction
- document preparation

AACI never finalizes a health act by itself.
Anything regulatory remains draft until the human gate resolves it.

## Core rule

HealthOS may process operational data, but directly identifying data is strongly separated, protected, pseudonymized, and reidentified only via governed flows.

## Deployment stance

Canonical minimum deployment:
- single Apple Silicon host
- macOS
- local PostgreSQL
- canonical filesystem store
- launchd-supervised local services
- private mesh/VPN access

Future deployment:
- multi-node private mesh/cloud
- same ontology
- changed topology only
