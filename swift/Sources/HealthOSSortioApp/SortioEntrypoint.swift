import Foundation
import HealthOSCore

// Sortio is the patient sovereignty interface for HealthOS.
// This target is a scaffold placeholder.
// No final UI shell or governed user-agent session flow is implemented in STR-005.
// Architecture: docs/architecture/12-sortio.md
// Governance contracts: HealthOSCore/UserSovereigntyContracts.swift
@main
struct SortioEntrypoint {
    static func main() {
        let args = CommandLine.arguments
        if args.contains("--smoke-test") {
            print("HealthOSSortio scaffold: smoke OK (no final UI, no clinical authority)")
            exit(0)
        }
        print("HealthOSSortio: scaffold placeholder - no final UI shell, no session behavior, no clinical authority (see docs/architecture/12-sortio.md)")
    }
}
