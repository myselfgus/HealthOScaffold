# Skill: storage and de-identification

## Purpose
Guide an AI working on storage, object metadata, de-identification, and re-identification control without collapsing the system into a blind vault.

## Scope
- object paths
- SQL metadata linkage
- lawfulContext usage
- direct identifier separation
- re-identification gating
- integrity/hash behavior

## Mandatory mindset
- HealthOS must process operational content
- direct identifiers must remain separated and strongly protected
- convenience is never a valid reason to touch re-identification mappings

## Never do
- put raw direct identifiers into casual operational payloads or path names
- blur direct-identifier layer with operational-content layer
- silently repair integrity mismatches in place
- treat lawfulContext as optional decoration

## Required outputs
- canonical path choice
- owner/layer reasoning
- lawful access explanation
- integrity implications
- audit/provenance implications when access is sensitive
