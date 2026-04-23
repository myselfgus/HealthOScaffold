# AI skills index

This directory contains reusable AI execution skills specific to HealthOS.

## Available skills

- `core-governance-skill.md`
  For identity, consent, habilitation, provenance, gate semantics, and deny/failure discipline.

- `storage-and-deidentification-skill.md`
  For filesystem/sql/object path design, lawfulContext use, de-identification, re-identification control, and integrity posture.

- `aaci-runtime-skill.md`
  For AACI session modes, subagent boundaries, provider routing, and draft production.

- `app-boundary-skill.md`
  For keeping Scribe, Sortio, and CloudClinic aligned with core law instead of leaking logic.

- `ops-mesh-skill.md`
  For local-first operations, mesh policy, launchd supervision, backup/restore discipline, and remote admin posture.

- `ml-governance-skill.md`
  For offline evaluation, dataset governance, adapter promotion, rollback, and provider benchmarking.

## Usage rule

Before editing a domain, an AI should read:
1. the master execution plan
2. the relevant TODO file
3. the architecture file(s)
4. the matching skill file in this directory

## Purpose

Skills are meant to preserve architecture under repeated AI execution. They are not generic coding tips; they are domain-specific operating constraints.
