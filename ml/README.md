# ml/

Create ML training scaffolds for HealthOS on-device models.

This directory contains training pipelines for on-device ML models used within the HealthOS platform. All models produced here are inference aids only — they are not clinical authority, not law engines, and not consent or gate surfaces. Every model must pass `ModelGovernance` review and have a provenance record before it may be loaded by any HealthOS runtime.

## Structure

```
ml/
└── transcript-normalizer/
    └── TrainTranscriptNormalizer.swift   Training scaffold for raw → normalized transcript classification
```

## transcript-normalizer

`TrainTranscriptNormalizer.swift` is a scaffold training script that uses the Apple Create ML framework to train a text classification model mapping raw speech-to-text output to normalized transcript text (corrected medical terminology, punctuation, and casing).

**Current maturity: scaffold stub.** The training data loader calls `fatalError` and must be replaced with a governed, de-identified annotated corpus before any real training run. Model parameters are placeholder values requiring baseline experimentation.

**To run (requires macOS with Create ML):**
```bash
swift ml/transcript-normalizer/TrainTranscriptNormalizer.swift
```

**Output destination:** `swift/Sources/HealthOSProviders/Resources/TranscriptNormalizer.mlmodel`

The model is loaded and enabled via `HealthOSProviders/ModelGovernance`. It must not be placed in `Resources/` or referenced by any provider until `ModelGovernance` approves it and a provenance record is written.

## Constraints

- All models must run on-device only. Remote training pipelines are not permitted.
- Training data must be de-identified. Raw patient identifiers (CPF, name, DOB) must never appear in training corpora.
- No model ships without explicit `ModelGovernance` approval and a provenance record.
- Scaffold training stubs must not be executed against real patient data.
- Models are inference aids. They do not produce clinical decisions, consent outcomes, or gate resolutions.
