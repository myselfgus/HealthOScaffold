// Boundary (Tier 3) — the only surface Stages are permitted to consume.
// Stages must import HealthOSBoundary only; never Tier 1/2 modules directly.
// This module exposes mediated, Stage-safe views: facades, safe refs, command/result envelopes,
// degraded-state views, and mediated session surfaces.
// See: docs/execution/21-structural-ontology-and-product-readiness-plan.md
//
// SCAFFOLD: expose facades and envelopes once Tier 2 surfaces stabilise.
import Foundation
import HealthOSCore
import HealthOSGOS
import HealthOSAACI
import HealthOSMSR
import HealthOSAsyncRuntime
import HealthOSUserAgentRuntime
import HealthOSServiceRuntime
import HealthOSSessionRuntime

public enum Boundary {
    // Placeholder — Tier 3 mediated surface pending facade implementation.
}
