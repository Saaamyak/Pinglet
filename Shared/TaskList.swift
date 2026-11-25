import SwiftUI

// The lists a task can belong to, each with a soft color (matches the approved design).
enum TaskList: String, CaseIterable, Identifiable {
    case work
    case personal
    case home
    case health

    var id: String { rawValue }

    var name: String {
        switch self {
        case .work: return "Work"
        case .personal: return "Personal"
        case .home: return "Home"
        case .health: return "Health"
        }
    }

    var color: Color {
        switch self {
        case .work:     return Color(red: 0.37, green: 0.36, blue: 0.90) // indigo  #5E5CE6
        case .personal: return Color(red: 0.19, green: 0.78, blue: 0.71) // teal    #30C7B5
        case .home:     return Color(red: 1.00, green: 0.62, blue: 0.04) // orange  #FF9F0A
        case .health:   return Color(red: 1.00, green: 0.39, blue: 0.51) // pink    #FF6482
        }
    }
}

// App-wide accent color (the indigo from the design).
enum AppTheme {
    static let accent = Color(red: 0.37, green: 0.36, blue: 0.90) // #5E5CE6
}
