# Swift modules

Swift now hosts:
- native-side domain and governance contracts
- runtime/provider abstractions
- shared first-slice executable support wiring
- CLI validation entry point
- a minimal macOS SwiftUI Scribe validation app (`HealthOSScribeApp`)

The current app surface still lives inside SwiftPM for minimal wiring discipline.
Future fuller app packaging may still move to a dedicated Xcode project when that becomes necessary.
