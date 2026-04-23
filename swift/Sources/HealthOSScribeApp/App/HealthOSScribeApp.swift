import Darwin
import SwiftUI

@main
struct HealthOSScribeApp: App {
    @State private var model = ScribeFirstSliceViewModel()

    var body: some Scene {
        WindowGroup("Scribe First Slice") {
            ScribeFirstSliceView(model: model)
                .task {
                    await model.loadIfNeeded()
                    if model.smokeTestMode {
                        let success = await model.runSmokeTest()
                        fflush(stdout)
                        exit(success ? 0 : 1)
                    }
                }
        }
    }
}
