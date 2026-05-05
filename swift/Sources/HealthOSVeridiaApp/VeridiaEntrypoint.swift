import Foundation
import HealthOSCore

// Veridia is the patient health identity app for HealthOS.
// This target is a scaffold placeholder.
// No final UI shell or governed patient agent session flow is implemented.
// Architecture: docs/architecture/12-veridia.md
// Governance contracts: HealthOSCore/UserSovereigntyContracts.swift
// Veridia consumes Core-mediated identity, key custody, consent, access trail, and export surfaces.
// Veridia is not Core law, not the User-Agent Runtime, and has no clinical authority.
@main
struct VeridiaEntrypoint {
    static func main() {
        let args = CommandLine.arguments
        if args.contains("--smoke-test") {
            print("HealthOSVeridia scaffold: smoke OK (no final UI, no clinical authority)")
            exit(0)
        }
        print("HealthOSVeridia: patient health identity app scaffold placeholder - no final UI shell, no session behavior, no clinical authority (see docs/architecture/12-veridia.md)")
    }
}
