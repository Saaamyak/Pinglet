import SwiftUI

// Task priority. Higher priority sorts to the top within each section.
enum Priority: Int, CaseIterable, Identifiable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .none: return "None"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    // SF Symbol shown on the task row (nil for None).
    var symbol: String? {
        switch self {
        case .none: return nil
        case .low: return "flag"
        case .medium: return "flag.fill"
        case .high: return "exclamationmark.2"
        }
    }

    var tint: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low, .none: return .secondary
        }
    }
}
