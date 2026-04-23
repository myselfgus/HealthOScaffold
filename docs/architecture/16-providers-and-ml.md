# Providers and ML

## Provider classes
- LanguageModelProvider
- SpeechToTextProvider
- EmbeddingProvider
- RetrievalProvider
- FineTuningProvider

## Principles
- provider choice is task-dependent
- local/private-first where quality permits
- remote fallback only via explicit policy
- provider routing belongs to AACI/runtime orchestration, not to app UIs

## Offline ML boundary
Python remains the offline ML boundary for:
- datasets
- evaluation
- adapter jobs
- promotion/rollback logic

## Open tasks
- define benchmark matrix
- define model registry lifecycle
- define adapter promotion path
- define dataset governance and de-identification policy for training
