import SwiftUI

// A single task row: a tappable completion circle, the title, and a small meta line
// (reminder time + list dot/name). Styling leans on the system so it adopts Liquid Glass.
struct TaskRowView: View {
    let item: TodoItem
    var onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(item.list.color)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(item.title)
                        .font(.body)
                        .strikethrough(item.isDone)
                        .foregroundStyle(item.isDone ? .secondary : .primary)
                    if !item.isDone, let symbol = item.priority.symbol {
                        Image(systemName: symbol)
                            .font(.caption)
                            .foregroundStyle(item.priority.tint)
                    }
                }

                HStack(spacing: 6) {
                    if let date = item.reminderDate {
                        Text(date, format: .dateTime.hour().minute())
                            .foregroundStyle(item.isOverdue ? .red : .secondary)
                    }
                    Circle()
                        .fill(item.list.color)
                        .frame(width: 6, height: 6)
                    Text(item.list.name)
                        .foregroundStyle(.secondary)
                    if item.repeatRule != .never {
                        Image(systemName: "repeat")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.caption)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}
