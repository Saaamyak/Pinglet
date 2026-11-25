import SwiftData

// One SwiftData container, stored in the shared App Group so BOTH the app and the widget
// open the same database. If the App Group isn't available (e.g. a signing limitation on a
// free account), we fall back to a local store so the app still runs — the widget just
// won't share data in that case.
enum SharedModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([TodoItem.self])

        let groupConfig = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier(AppGroup.id)
        )
        if let container = try? ModelContainer(for: schema, configurations: groupConfig) {
            return container
        }

        // Fallback: a plain local store (keeps the app working no matter what).
        let localConfig = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: localConfig)
        } catch {
            fatalError("Could not create a ModelContainer: \(error)")
        }
    }()
}
