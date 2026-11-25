import Foundation

// How a reminder repeats. Drives the notification trigger in NotificationManager.
enum RepeatRule: String, CaseIterable, Identifiable {
    case never
    case daily
    case weekdays
    case weekly

    var id: String { rawValue }

    var name: String {
        switch self {
        case .never: return "Never"
        case .daily: return "Daily"
        case .weekdays: return "Weekdays"
        case .weekly: return "Weekly"
        }
    }
}
