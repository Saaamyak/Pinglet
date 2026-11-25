import Foundation

// How the Today screen groups tasks into sections. Order here is the order on screen.
enum Bucket: CaseIterable {
    case overdue
    case today
    case upcoming
    case someday
    case completed

    var title: String {
        switch self {
        case .overdue:   return "Overdue"
        case .today:     return "Today"
        case .upcoming:  return "Upcoming"
        case .someday:   return "No date"
        case .completed: return "Completed"
        }
    }

    // Which section a given task belongs in.
    func contains(_ item: TodoItem) -> Bool {
        if item.isDone { return self == .completed }

        let now = Date()
        switch self {
        case .completed:
            return false
        case .someday:
            return item.reminderDate == nil
        case .overdue:
            guard let date = item.reminderDate else { return false }
            return date < now
        case .today:
            guard let date = item.reminderDate else { return false }
            return date >= now && Calendar.current.isDateInToday(date)
        case .upcoming:
            guard let date = item.reminderDate else { return false }
            return date >= now && !Calendar.current.isDateInToday(date)
        }
    }
}
