# Providers and ML Governance

## Capability honesty
HealthOS scaffold enforces capability honesty at runtime:
- If a semantic embedding provider is not registered or is a stub not marked as 'real', the orchestrator must return `.unavailable` or fallback to `.lexical` (if permitted by policy).
- It is strictly forbidden for the retrieval engine to return 'fake' semantic scores or fabricated matches when no provider is executing.
- Capability status is explicitly signaled in `TranscriptionOutput` and `GovernedRetrievalResult`.
