# AACI runtime

AACI = Ambient-Agentic Clinical Intelligence.

## Purpose
Run alongside health work to reduce bureaucratic and operational burden without taking clinical authority.

## Session modes
- encounter
- chart review
- document close
- post-visit
- pre-briefing
- admin block
- handoff

## Path classes
- hot path: minimal interruption, immediate session assistance
- warm path: seconds/minutes acceptable, draft preparation and organization
- cold path: deferred work handed to async runtime

## Initial subagents
- CaptureAgent
- TranscriptionAgent
- IntentionAgent
- ContextRetrievalAgent
- DraftComposerAgent
- TaskExtractionAgent
- ReferralDraftAgent
- PrescriptionDraftAgent
- NoteOrganizerAgent
- RecordLocatorAgent

## Invariants
- AACI never finalizes a health act
- AACI produces drafts, retrieval outputs, and structured assistance
- every meaningful step should be provenance-capable
- access remains bounded by consent/habilitation/context
