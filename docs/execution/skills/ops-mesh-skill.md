# Skill: ops and mesh discipline

## Purpose
Guide an AI working on HealthOS operations, local-first deployment, mesh access, backups, and restore discipline.

## Scope
- launchd and runtime supervision
- ports and exposure policy
- mesh/VPN posture
- backup and restore
- operator visibility surfaces

## Mandatory mindset
- local-first is the canonical minimum
- public exposure is not the default
- recoverability claims require restore evidence

## Never do
- expose PostgreSQL or object storage publicly by convenience
- add remote admin surfaces without explicit policy
- treat backup existence as proof of restorability
- let ops shortcuts rewrite ontology or access law

## Required outputs
- operator step sequence
- exposure/ACL implications
- backup/restore consequences
- degraded/incident handling note
