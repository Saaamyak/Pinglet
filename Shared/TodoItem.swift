import Foundation
import SwiftData

// One to-do item. `@Model` makes SwiftData save/load it automatically.
// Every stored property has a default value so SwiftData can migrate the database
// cleanly if we add fields later.
@Model
final class TodoItem {
    var id: UUID = UUID()
    var title: String = ""
    var isDone: Bool = false
    var dueDate: Date?
    var reminderDate: Date?
    var createdAt: Date = Date()
    // We store the list as a String ("work", "home", …) and expose a typed accessor below.
    var listRaw: String = TaskList.personal.rawValue
    var priorityRaw: Int = 0
    var repeatRaw: String = RepeatRule.never.rawValue

    init(title: String, reminderDate: Date? = nil, list: TaskList = .personal,
         priority: Priority = .none, repeatRule: RepeatRule = .never) {
        self.id = UUID()
        self.title = title
        self.isDone = false
        self.reminderDate = reminderDate
        self.dueDate = reminderDate
        self.createdAt = Date()
        self.listRaw = list.rawValue
        self.priorityRaw = priority.rawValue
        self.repeatRaw = repeatRule.rawValue
    }

    // Typed view over `listRaw`, so the rest of the app works with the TaskList enum.
    var list: TaskList {
        get { TaskList(rawValue: listRaw) ?? .personal }
        set { listRaw = newValue.rawValue }
    }

    var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .none }
        set { priorityRaw = newValue.rawValue }
    }

    var repeatRule: RepeatRule {
        get { RepeatRule(rawValue: repeatRaw) ?? .never }
        set { repeatRaw = newValue.rawValue }
    }

    // True when this task has a reminder in the past and isn't finished yet.
    var isOverdue: Bool {
        guard !isDone, let date = reminderDate else { return false }
        return date < Date()
    }
}
