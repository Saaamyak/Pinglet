import Foundation
import UserNotifications

// Schedules and cancels local reminder notifications, including repeats.
// Lives in Shared so both the app and the widget (ToggleTaskIntent) can use it.
enum NotificationManager {

    static func requestAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // Remove the task's pending notification(s) — covers the base id and the per-weekday ids.
    static func cancel(_ item: TodoItem) {
        let base = item.id.uuidString
        let ids = [base] + (2...6).map { "\(base)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    static func schedule(for item: TodoItem) {
        cancel(item)
        guard let date = item.reminderDate, !item.isDone else { return }

        let cal = Calendar.current
        let hourMinute = cal.dateComponents([.hour, .minute], from: date)

        func makeContent() -> UNMutableNotificationContent {
            let content = UNMutableNotificationContent()
            content.title = item.title
            content.body = "Reminder · \(item.list.name)"
            content.sound = .default
            return content
        }
        func add(_ id: String, _ trigger: UNNotificationTrigger) {
            let request = UNNotificationRequest(identifier: id, content: makeContent(), trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }

        switch item.repeatRule {
        case .never:
            guard date > Date() else { return }
            let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            add(item.id.uuidString, UNCalendarNotificationTrigger(dateMatching: comps, repeats: false))

        case .daily:
            add(item.id.uuidString, UNCalendarNotificationTrigger(dateMatching: hourMinute, repeats: true))

        case .weekly:
            var comps = hourMinute
            comps.weekday = cal.component(.weekday, from: date)
            add(item.id.uuidString, UNCalendarNotificationTrigger(dateMatching: comps, repeats: true))

        case .weekdays:
            // Monday(2) … Friday(6)
            for weekday in 2...6 {
                var comps = hourMinute
                comps.weekday = weekday
                add("\(item.id.uuidString)-\(weekday)",
                    UNCalendarNotificationTrigger(dateMatching: comps, repeats: true))
            }
        }
    }

    static func reschedule(for item: TodoItem) {
        schedule(for: item)
    }
}
