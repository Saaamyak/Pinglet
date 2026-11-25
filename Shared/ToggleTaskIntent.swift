import AppIntents
import SwiftData
import WidgetKit

// Powers the interactive widget: tapping a task's circle on the home screen runs this,
// toggles the task done in the shared database, and refreshes the widget — no app launch.
struct ToggleTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Task Done"

    @Parameter(title: "Task ID")
    var idString: String

    init() {}

    init(id: UUID) {
        self.idString = id.uuidString
    }

    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: idString) else { return .result() }

        let context = ModelContext(SharedModelContainer.shared)
        let descriptor = FetchDescriptor<TodoItem>(
            predicate: #Predicate { $0.id == uuid }
        )
        if let item = try context.fetch(descriptor).first {
            item.isDone.toggle()
            try context.save()
            if item.isDone {
                NotificationManager.cancel(item)
            } else {
                NotificationManager.schedule(for: item)
            }
        }

        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
