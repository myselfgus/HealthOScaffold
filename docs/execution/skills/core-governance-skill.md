# Skill: core governance

## Purpose
Guide an AI working on the non-negotiable legal/governance core of HealthOS.

## Scope
- identity
- CPF-rooted civil linkage
- professional records
- service membership
- habilitation
- consent
- provenance
- gate request and gate resolution
- access/finality checks

## Mandatory mindset
- be conservative
- prefer explicit invariants over convenience
- assume that ambiguity in governance propagates damage to every runtime and app

## Never do
- let apps define governance rules
- treat consent as a boolean instead of scoped/time-bounded object
- treat habilitation as generic auth
- collapse provenance into logging-only semantics
- let gate become optional review UI

## Required outputs when editing this domain
- machine-readable schema or typed contract
- prose contract document if semantics are non-obvious
- definition of failure/deny paths
- definition of audit/provenance obligations
