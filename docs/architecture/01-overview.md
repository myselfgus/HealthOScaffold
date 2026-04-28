# HealthOS canonical overview

## What HealthOS is

HealthOS is the full sovereign computational environment for health operations.

HealthOScaffold is the historical repository name and initial scaffolding phase for HealthOS. All implemented architecture, contracts, runtimes, apps, tests, and documentation in this repository are part of HealthOS unless explicitly marked experimental or deprecated. "Scaffold" describes maturity, not project identity.

HealthOS is health-exclusive by ontology.
It is not generic cloud infrastructure with healthcare plugins.
Its core primitives are health-native from the start, including:
- professional record (`RegistroProfissional`) and habilitation windows
- consent with explicit clinical purpose/finality
- mandatory human gate before regulatory effectuation
- clinical-operational drafts and finalized documents with lineage
- provenance and audit semantics anchored in health operations

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

The system is not zero-knowledge against its own core.
The core must see operational content to apply law and produce governed runtime behavior.

## Deployment stance

Canonical minimum deployment:
- single Apple Silicon host
- macOS
- local PostgreSQL
- canonical filesystem store
- launchd-supervised local services
- private mesh connectivity

Production-shaping projection:
- operator-owned Apple Silicon sovereign health fabric
- physically distributed when needed
- ontologically one HealthOS environment
- online access through private mesh surfaces only
- same ontology, contracts, and law across topology changes
