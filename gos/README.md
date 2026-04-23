# GOS authoring workspace

This directory holds human/AI-facing authoring artifacts for Governed Operational Spec (GOS).

## Purpose

GOS authoring artifacts are not runtime law.
They are declarative source material that should compile into canonical JSON bundles consumed by HealthOS runtimes.

## Current contents

- `templates/blank.gos.yaml`: blank authoring template for new GOS specs

## Authoring rule

Authoring here should remain:
- generic
- declarative
- scenario-agnostic unless a future work unit explicitly adds a reviewed scenario pack

## Current non-goal

This workspace is not yet a library of activated protocol packs.
At this stage it exists to standardize authoring posture and compiler input shape.
