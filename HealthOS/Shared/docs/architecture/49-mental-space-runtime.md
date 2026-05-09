# MSR — Mental Space Runtime

## Purpose

MSR (Mental Space Runtime) is the HealthOS runtime domain for staged linguistic and cognitive derived artifacts.

It is not a replacement for the async runtime. The async runtime remains the queue, retry, idempotency, dead-letter, and backpressure substrate. Mental Space Runtime defines the artifact pipeline, stage dependencies, provider posture, provenance, and app-safe clinician insight surface.

## Stage order

The stage order is fixed:

1. ASL: Analise Sistemica da Linguagem
2. VDLP: Vetores-Dimensao do Espaco-Campo Mental
3. GEM: Grafo do Espaco-Mental

Downstream stages fail closed when upstream artifacts are missing or degraded:

- MSR receives a normalized transcript as input from `HealthOSSessionRuntime`.
- VDLP requires ready ASL plus the transcript lineage.
- GEM requires ready transcript, ASL, and VDLP lineage.

## Artifact posture

Mental Space outputs are derived, gated artifacts.

They may be surfaced as clinician insight context, but they are not:

- automatic diagnosis
- final clinical authority
- consent, habilitation, finality, or gate law
- regulatory/provider effectuation
- proof of production-ready ML capability

The shared artifact metadata records:

- source transcript reference
- stage version and prompt version
- model provider and model id when available
- input and output hashes
- lawful-context summary without direct identifiers
- clinician review status
- limitations
- `legalAuthorizing = false`
- `gateStillRequired = true`

Raw audio and raw transcript material remain operational content. Mental Space outputs are stored as `derived-artifacts`.

## Boundary with session runtime

Normalization does not belong to MSR.

The session pipeline is:

1. capture / transcription
2. transcript normalization
3. MSR (`ASL -> VDLP -> GEM`)

`HealthOSSessionRuntime` owns transcription normalization, speaker cleanup, and transcript preparation. MSR starts only after a normalized transcript exists.

For v1:

- transcript normalization prefers Apple/local language-model providers
- remote fallback is denied unless a future explicit policy changes this
- stub model output is never persisted as a real normalized transcript
- unavailable or stub-only providers produce explicit degraded state

ASL, VDLP, and GEM remain staged contracts in this work unit. Their existing prompt-engineered scripts should initially be wrapped behind an adapter boundary rather than rewritten wholesale. Future remote provider use for these heavier stages must remain explicit, lawful-context checked, and provenance recorded.

## App-safe surface

Scribe may show:

- stage status
- provider/model status
- derived artifact availability
- clinician review status
- concise stage summary

Scribe must not expose raw prompt internals, raw artifact JSON, direct identifiers, or ungated diagnostic claims.

## Current executable posture

The scaffold now implements transcript normalization in `HealthOSSessionRuntime`:

- after a non-empty transcript is persisted, `SessionRunner` requests transcript normalization
- a real local language model can return normalized transcript text
- the normalized transcript is persisted as a derived artifact before MSR execution
- provenance records transcript-normalization lineage separately from MSR stage lineage
- Scribe receives separate mediated surfaces for transcript normalization and MSR

ASL, VDLP, and GEM remain scaffolded contracts/job kinds only in this wave.

## Module structure

The `HealthOSMSR` Swift module (`HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSMSR/`) is the designated home for the pipeline orchestrator and stage executors. It is registered in `Package.swift` and depends on `HealthOSCore` for contracts.

```
HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSMSR/
├── MSRPipeline.swift                  — module root; documents layout and stage order
├── Prompts/
│   ├── asl-system.md                  — ASL clinical prompts (clinically validated, 400 patients)
│   ├── vdlp-system.md                 — VDLP 15-dimension prompts (validated, 400 patients)
│   └── gem-system.md                  — GEM 4-layer graph prompts (validated, 400 patients)
└── Executors/
    ├── ASLExecutor.swift              — dispatch boundary for ASL stage
    ├── VDLPExecutor.swift             — dispatch boundary for VDLP stage
    └── GEMArtifactBuilder.swift       — dispatch boundary for GEM stage
```

### Prompt files as clinical contracts

The prompt files in `Prompts/` are extracted verbatim from the legacy TypeScript scripts tested on 400 patients and now archived at `HealthOS/Shared/docs/reference/mental-space-legacy/` (including `4-asl.ts`, `5-vdlp.ts`, `6-gem.ts`). They are version-controlled as the canonical clinical contracts for each stage. Their content must not be altered without re-validation against the clinical cohort. The Swift executors are dispatch and provenance boundaries only — they load these prompts at runtime and route them to the appropriate provider.

### Executor pattern

Each executor exposes a protocol (`ASLExecuting`, `VDLPExecuting`, `GEMArtifactBuilding`) so the orchestrator can inject different provider implementations (real, stub, test). All executors throw on any error — no silent degradation. The input dependency chain is enforced at call sites:

- `ASLExecutor`: requires non-empty transcription
- `VDLPExecutor`: requires ready ASL blob + non-empty patient speech
- `GEMArtifactBuilder`: requires all three (transcription + ASL + VDLP); any missing upstream throws `.triadIncomplete`

### Provider posture per stage

| Stage | Model | Temperature | Max tokens | Chunking threshold |
|-------|-------|-------------|------------|--------------------|
| ASL   | Sonnet (Haiku via flag) | 0 | 60k | 10k tokens; parallel batches of 3 |
| VDLP  | Sonnet (Haiku via flag) | 0 | 60k | 10k tokens; speech only split |
| GEM   | Sonnet | 0.2 | 60k | 50k tokens; transcription only split |

All three stages require extended prompt caching (`anthropic-beta: prompt-caching-2024-07-31,extended-cache-ttl-2025-04-11`, ephemeral TTL 1h) — the system prompts are large and caching is mandatory for cost control.

### Current state

ASL, VDLP, and GEM executor paths are provider-backed through `HealthOSProviders` with fail-closed dependency validation and stage provenance.

Legacy TypeScript scripts are archived reference implementations at `HealthOS/Shared/docs/reference/mental-space-legacy/`; they are not the active runtime pipeline.

Contracts and types remain in `HealthOSCore`. Transcript normalization lives in `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/Normalization/NormalizationExecutor.swift`. The active MSR orchestrator and stage executors live in `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSMSR/`.
