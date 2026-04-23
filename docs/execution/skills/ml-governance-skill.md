# Skill: ML governance

## Purpose
Guide an AI working on provider benchmarks, dataset governance, adapter promotion, and rollback without contaminating online runtime assumptions.

## Scope
- benchmark artifacts
- routing policy interpretation
- dataset lineage and de-identification posture
- adapter/model promotion lifecycle
- rollback conditions

## Mandatory mindset
- online runtime safety comes before model ambition
- offline ML is subordinate to governance, not vice versa
- provider choice must stay task-class aware and privacy-aware

## Never do
- send live sensitive data into tuning flow by convenience
- promote an adapter without evaluation lineage
- remove rollback path just because a model scores better in one dimension
- let provider routing bypass task-class privacy posture

## Required outputs
- evaluation summary
- dataset lineage statement
- promotion or rejection rationale
- fallback/rollback note
- privacy posture statement
