import WidgetKit
import SwiftUI
import SwiftData

// A lightweight, codable snapshot of a task for the widget timeline.
struct TaskSnapshot: Identifiable {
    let id: UUID
    let title: String
    let timeText: String?
    let overdue: Bool
    let listRaw: String

    var color: Color { (TaskList(rawValue: listRaw) ?? .personal).color }
}

struct PingletEntry: TimelineEntry {
    let date: Date
    let tasks: [TaskSnapshot]
    let remaining: Int
    let doneCount: Int
    let totalCount: Int
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PingletEntry {
        PingletEntry(date: .now, tasks: Self.sample, remaining: 2, doneCount: 1, totalCount: 6)
    }

    func getSnapshot(in context: Context, completion: @escaping (PingletEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PingletEntry>) -> Void) {
        let entry = loadEntry()
        // Refresh periodically so times/overdue stay current.
        let next = Date().addingTimeInterval(15 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func loadEntry() -> PingletEntry {
        let context = ModelContext(SharedModelContainer.shared)
        let all = (try? context.fetch(FetchDescriptor<TodoItem>())) ?? []

        let open = all.filter { !$0.isDone }
            .sorted { ($0.reminderDate ?? .distantFuture) < ($1.reminderDate ?? .distantFuture) }

        let snaps = open.prefix(8).map { item in
            TaskSnapshot(
                id: item.id,
                title: item.title,
                timeText: item.reminderDate.map(Self.timeString),
                overdue: item.isOverdue,
                listRaw: item.listRaw
            )
        }

        return PingletEntry(
            date: .now,
            tasks: Array(snaps),
            remaining: max(0, open.count - snaps.count),
            doneCount: all.filter { $0.isDone }.count,
            totalCount: all.count
        )
    }

    private static func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    static let sample: [TaskSnapshot] = [
        TaskSnapshot(id: UUID(), title: "Call the plumber", timeText: "09:30", overdue: true, listRaw: "home"),
        TaskSnapshot(id: UUID(), title: "Submit expense report", timeText: "11:00", overdue: false, listRaw: "work"),
        TaskSnapshot(id: UUID(), title: "Pick up prescription", timeText: "14:00", overdue: false, listRaw: "health"),
    ]
}

struct PingletWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: PingletEntry

    private var rowCount: Int {
        switch family {
        case .systemSmall: return 3
        case .systemLarge: return 8
        default: return 4
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Today")
                        .font(.headline).fontWeight(.bold)
                    if entry.totalCount > 0 {
                        Text("\(entry.doneCount) of \(entry.totalCount) done")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppTheme.accent)
                    .font(.system(size: 15))
            }

            if entry.tasks.isEmpty {
                Spacer()
                Text("All clear")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                ForEach(entry.tasks.prefix(rowCount)) { task in
                    row(task)
                }
                if entry.remaining > 0 {
                    Text("+\(entry.remaining) more")
                        .font(.caption2).foregroundStyle(.secondary)
                        .padding(.top, 1)
                }
            }

            Spacer(minLength: 0)
        }
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }

    private func row(_ task: TaskSnapshot) -> some View {
        HStack(spacing: 8) {
            Button(intent: ToggleTaskIntent(id: task.id)) {
                Image(systemName: "circle")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(task.color)
            }
            .buttonStyle(.plain)

            Text(task.title)
                .font(.caption)
                .lineLimit(1)

            Spacer(minLength: 4)

            if let time = task.timeText {
                Text(time)
                    .font(.caption2).fontWeight(.semibold)
                    .foregroundStyle(task.overdue ? .red : .secondary)
            }
        }
    }
}

struct PingletWidget: Widget {
    let kind = "PingletWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PingletWidgetView(entry: entry)
        }
        .configurationDisplayName("Today")
        .description("Your next tasks — tap a circle to complete one.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
