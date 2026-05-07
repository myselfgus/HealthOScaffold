# Scribe

Professional clinical workspace Stage for HealthOS. Scribe consumes `HealthOSBoundary` only and never holds clinical authority, consent law, or Core governance.

**Architecture:** `docs/architecture/11-scribe.md`
**Executable surface:** [`swift/Sources/HealthOSScribeStage/`](../../swift/Sources/HealthOSScribeStage/)
**Design surface:** [`HealthOSDesignSystem/ui_kits/scribe/`](../../HealthOSDesignSystem/ui_kits/scribe/)

## Session Lifecycle

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F6F8FB', 'primaryBorderColor': '#D6DEE8', 'primaryTextColor': '#1D2733', 'lineColor': '#5B6B7C', 'edgeLabelBackground': '#F6F8FB', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
stateDiagram-v2
    [*] --> Idle : launch
    Idle --> Opening : startSession()
    Opening --> Active : habilitation + consent valid
    Opening --> Failed : governance deny
    Active --> GateReview : gate request raised
    Active --> Degraded : transcription / retrieval degraded
    Degraded --> GateReview : gate request raised (degraded path)
    GateReview --> Closed : gate approved → final SOAP + provenance
    GateReview --> Withheld : gate rejected
    Closed --> [*]
    Withheld --> [*]
    Failed --> [*]
```

## Screens

| Screen | Purpose |
| :--- | :--- |
| Login / service selection | Identify professional, select service context |
| Active session | Capture, transcript, real-time workspace |
| Context pane | Patient history, retrieved context package |
| Drafts pane | SOAP draft, referral, prescription drafts |
| Gate queue | Clinician review — approve or reject final artifact |
| Session history | Closed sessions and provenance trail |

## Maturity

Minimal SwiftUI validation surface (`HealthOSScribeStage`) is operational for smoke testing.
Full Liquid Glass UI shell, final gate panel, and derived-draft workflows are pending Tier 2 stabilization.
Scribe never owns governance law — all authority flows via `HealthOSBoundary`.
