# Providers and ML Governance

`HealthOSProviders` is the Tier 2 Swift runtime provider-adapter module. `HealthOS/Support` is the visible support root for governed provider-support tooling, ops, Python, and Create ML/Core ML/MLX scaffolds. Support may assist provider experiments and local model preparation, but it is not the runtime import target and does not grant provider, clinical, or Core-law authority.

## Capability honesty
HealthOS scaffold enforces capability honesty at runtime:
- If a semantic embedding provider is not registered or is a stub not marked as 'real', the orchestrator must return `.unavailable` or fallback to `.lexical` (if permitted by policy).
- It is strictly forbidden for the retrieval engine to return 'fake' semantic scores or fabricated matches when no provider is executing.
- Capability status is explicitly signaled in `TranscriptionOutput` and `GovernedRetrievalResult`.
