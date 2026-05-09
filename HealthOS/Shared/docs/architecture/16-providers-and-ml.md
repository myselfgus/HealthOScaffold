# Providers and ML Governance

`HealthOSProviders` is the Tier 2 Swift runtime provider-adapter module. `HealthOS/Support` is the visible support root for governed provider-support tooling, ops, Python, and Create ML/Core ML/MLX scaffolds. Support may assist provider experiments and local model preparation, but it is not the runtime import target and does not grant provider, clinical, or Core-law authority.

## Capability honesty
HealthOS scaffold enforces capability honesty at runtime:
- If a semantic embedding provider is not registered or is a stub not marked as 'real', the orchestrator must return `.unavailable` or fallback to `.lexical` (if permitted by policy).
- It is strictly forbidden for the retrieval engine to return 'fake' semantic scores or fabricated matches when no provider is executing.
- Capability status is explicitly signaled in `TranscriptionOutput` and `GovernedRetrievalResult`.

## Governed AI agent provider policy

ADR-0014 formalizes that agents are governed identities, while LLMs/providers are selectable engines. Apple Silicon/local-first remains the preferred posture when appropriate, but it is not an absolute ban on external models. External provider routing is allowed only when explicit policy permits it and when the data layer, minimization, provenance, audit, and degraded-sovereignty posture pass validation.

`AgentProviderRoutingPolicy` records:
- Apple/local preference;
- allowed provider kinds;
- explicit external provider policy reference;
- operational-sensitive external allowance;
- allowed and denied data layers;
- model provenance requirement.

Provider routing must continue to deny direct identifiers and reidentification maps, and must not treat a model registry entry, local model, remote model, or Apple substrate capability as clinical/legal authority.
