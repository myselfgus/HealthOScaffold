# Skill: AACI runtime

## Purpose
Guide an AI working on the AACI runtime without letting it drift into clinician substitution or architectural confusion.

## Scope
- session modes
- subagent boundaries
- hot/warm/cold path routing
- provider routing
- drafts
- retrieval
- task extraction
- provenance hooks

## Mandatory mindset
- AACI assists work; it does not own clinical authority
- drafts before gate, always
- provider choice is operational, not ontological
- latency tolerance is acceptable when ergonomic savings are high

## Never do
- let AACI finalize a health act
- let a subagent read beyond its boundary just because it is convenient
- hardcode a single provider into core contracts
- leak gate semantics into draft production logic

## Required outputs when editing this domain
- bounded agent contract
- session/path classification
- provider routing rationale
- provenance emission points
- integration note with gate and core services
