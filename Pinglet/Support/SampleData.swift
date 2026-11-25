import Foundation
import SwiftData

// Dev-only sample tasks for screenshots/testing. Only runs when the app is launched
// with the PINGLET_SEED=1 environment variable, so it never affects normal use.
enum SampleData {
    static func seed(into context: ModelContext) {
        let cal = Calendar.current
        let now = Date()

        func todayAt(_ hour: Int, _ minute: Int, dayOffset: Int = 0) -> Date {
            let base = cal.date(byAdding: .day, value: dayOffset, to: now) ?? now
            return cal.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
        }

        let seeded: [TodoItem] = [
            TodoItem(title: "Call the plumber about the leak", reminderDate: todayAt(9, 30), list: .home, priority: .high),
            TodoItem(title: "Submit expense report", reminderDate: now.addingTimeInterval(60 * 90), list: .work),
            TodoItem(title: "Review Aarav's pull request", reminderDate: now.addingTimeInterval(60 * 180), list: .work),
            TodoItem(title: "Pick up prescription", reminderDate: todayAt(14, 0, dayOffset: 1), list: .health),
            TodoItem(title: "Buy Mom's birthday gift", list: .personal),
            TodoItem(title: "Water the plants", list: .home, repeatRule: .daily),
        ]
        for item in seeded { context.insert(item) }

        let done = TodoItem(title: "Morning run", list: .health)
        done.isDone = true
        context.insert(done)
    }
}
