# AACI runtime

AACI = Ambient-Agentic Clinical Intelligence.

## Purpose
Run alongside health work to reduce bureaucratic and operational burden without taking clinical authority.

## Session modes and bounded meaning
- encounter: live work session around patient/professional interaction
- chart review: pre/post review of records and context
- document close: finishing notes, referrals, prescriptions-as-drafts, and summaries
- post-visit: deferred cleanup and operational organization after encounter
- pre-briefing: context assembly before encounter
- admin block: service/operational work not tied to one live encounter
- handoff: transfer-oriented summary and pending-work structuring

## Session permission rule
A session mode does not itself authorize access.
It only defines the operational shape of the work.
Actual sensitive access still depends on consent, habilitation, finality, and service context.

## Path classes
- hot path: minimal interruption, immediate session assistance
- warm path: seconds/minutes acceptable, draft preparation and organization
- cold path: deferred work handed to async runtime

## Path allocation baseline
### hot path
- capture event ingestion
- local audio file capture reference intake
- partial transcription
- bounded context lookups needed during active work

### warm path
- SOAP composition
- note organization
- task extraction
- referral/prescription draft structuring

### cold path
- summarization across many artifacts
- reprocessing and cleanup
- future briefings and retrospective organization

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

## Subagent contracts
### CaptureAgent
Role:
- receives session input and normalizes it into capture events
Input boundary:
- active session input only, including seeded text and local audio file references
Output:
- capture events, audio refs, raw session items
Permissions:
- `session:read`, `capture:write`
Governance hooks:
- session validity
Never does:
- clinical interpretation or finalization

### TranscriptionAgent
Role:
- converts audio references into transcript material or explicit degraded/unavailable transcription state
Input boundary:
- audio refs or capture events only
Output:
- transcript fragments / transcript artifact refs / degraded transcription state
Permissions:
- `capture:read`, `transcript:write`
Governance hooks:
- service/session scoping
Never does:
- diagnosis or final artifact approval

## Current first-slice local audio path

The current executable slice now supports two lawful capture modes:
- seeded text, which remains the compatibility path
- local audio file reference, which is persisted into the service record area before transcription is attempted

For the current wave:
- audio capture is local-first and file-backed
- transcription may complete as `ready`, `degraded`, or `unavailable`
- degraded or unavailable transcription must remain visible to Scribe as runtime truth
- if transcription yields no searchable text, bounded retrieval must degrade honestly instead of widening scope or inventing context
- if transcription yields searchable text, bounded retrieval should stay deterministic/local while using simple clinical-operational metadata, recency, and intent-aware scoring
- the output consumed by downstream draft composition should be a structured context package rather than a raw string list

### IntentionAgent
Role:
- classifies session fragments into operational intent classes
Input boundary:
- transcript fragments and bounded session events
Output:
- intent labels and routing suggestions
Permissions:
- `transcript:read`, `intent:write`
Governance hooks:
- none beyond lawful session context
Never does:
- access expansion by itself

### ContextRetrievalAgent
Role:
- retrieves bounded patient/service context relevant to current task
Input boundary:
- retrieval request, patient/service identifiers, lawful session context
Output:
- structured context packages, retrieval summaries, or object references
Permissions:
- `patient:context:read`, `consent:check`, `habilitation:check`
Governance hooks:
- consent + habilitation + finality + service context
Never does:
- re-identification by convenience

### DraftComposerAgent
Role:
- composes structured drafts such as SOAP from session material and retrieved context
Input boundary:
- transcript/context/intention outputs
Output:
- draft artifacts only
Permissions:
- `draft:write`, `transcript:read`, `context:read`
Governance hooks:
- provenance capture
Never does:
- final artifact effectuation

### TaskExtractionAgent
Role:
- extracts operational follow-up items and pending work
Input boundary:
- transcripts, drafts, session outputs
Output:
- task lists / admin work items
Permissions:
- `session:read`, `task:write`
Governance hooks:
- provenance capture
Never does:
- create authoritative clinical acts

### ReferralDraftAgent
Role:
- structures referral drafts from bounded input
Input boundary:
- context, session materials, explicit referral intent
Output:
- referral draft
Permissions:
- `draft:write`, `context:read`
Governance hooks:
- provenance capture, service context
Never does:
- issue final referral without gate

Current first-slice executable slice status:
- now materialized as a typed draft-only derivative linked back to the same session/SOAP/context spine
- persists provenance-capable referral draft artifacts
- still does not issue or effectuate a referral in this wave

### PrescriptionDraftAgent
Role:
- structures prescription drafts from bounded input
Input boundary:
- explicit professional/session material and structured data
Output:
- prescription draft
Permissions:
- `draft:write`, `context:read`
Governance hooks:
- provenance capture, service context
Never does:
- create effective prescription without gate

Current first-slice executable slice status:
- now materialized as a typed draft-only derivative linked back to the same session/SOAP/context spine
- keeps medication suggestion/instructions as free-text draft material only
- still does not emit an effective prescription in this wave

### NoteOrganizerAgent
Role:
- reorganizes notes and session material into clearer structured forms
Input boundary:
- drafts and session material
Output:
- reorganized draft/note structure
Permissions:
- `draft:read`, `draft:write`
Governance hooks:
- provenance capture
Never does:
- widen access scope

### RecordLocatorAgent
Role:
- locates candidate records and object references relevant to a bounded query
Input boundary:
- patient/service-scoped retrieval request
Output:
- record/object references
Permissions:
- `record:index:read`, `consent:check`, `habilitation:check`
Governance hooks:
- lawful access basis
Never does:
- open restricted content without lawful context

## Invariants
- AACI never finalizes a health act
- AACI produces drafts, retrieval outputs, and structured assistance
- AACI may now derive SOAP, referral, and prescription drafts from the same bounded first-slice spine, but only SOAP finalization is effectable in the current wave
- AACI may rank and assemble bounded context locally, but it must surface weak or empty context honestly
- every meaningful step should be provenance-capable
- access remains bounded by consent/habilitation/context
- provider choice must not alter these invariants
