import SwiftUI
import SwiftData

// App entry point. Sets up the on-device SwiftData store and shows the Today screen.
// In Phase 5 we'll point this store at the shared App Group container so the widget
// can read the same tasks.
@main
struct PingletApp: App {
    var body: some Scene {
        WindowGroup {
            TodayView()
        }
        // Shared App Group database, so the widget sees the same tasks.
        .modelContainer(SharedModelContainer.shared)
    }
}
