import SwiftUI
import SwiftData
import WidgetKit

// The add / edit sheet. Pass an existing item to edit it, or nothing to create a new one.
struct AddEditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var editing: TodoItem?

    @State private var title = ""
    @State private var hasReminder = false
    @State private var reminderDate = Calendar.current.date(
        byAdding: .hour, value: 1, to: Date()) ?? Date()
    @State private var list: TaskList = .personal
    @State private var priority: Priority = .none
    @State private var repeatRule: RepeatRule = .never

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What do you need to do?", text: $title, axis: .vertical)
                }

                Section {
                    Toggle("Remind me", isOn: $hasReminder.animation())
                    if hasReminder {
                        DatePicker("Time", selection: $reminderDate)
                    }
                }

                Section("List") {
                    Picker("List", selection: $list) {
                        ForEach(TaskList.allCases) { taskList in
                            Label(taskList.name, systemImage: "circle.fill")
                                .foregroundStyle(taskList.color)
                                .tag(taskList)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { level in
                            Text(level.name).tag(level)
                        }
                    }
                    Picker("Repeat", selection: $repeatRule) {
                        ForEach(RepeatRule.allCases) { rule in
                            Text(rule.name).tag(rule)
                        }
                    }
                }
            }
            .navigationTitle(editing == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear(perform: loadIfEditing)
        }
    }

    private func loadIfEditing() {
        guard let item = editing else { return }
        title = item.title
        list = item.list
        priority = item.priority
        repeatRule = item.repeatRule
        if let date = item.reminderDate {
            hasReminder = true
            reminderDate = date
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let reminder = hasReminder ? reminderDate : nil

        if let item = editing {
            item.title = trimmed
            item.list = list
            item.priority = priority
            item.repeatRule = repeatRule
            item.reminderDate = reminder
            item.dueDate = reminder
            NotificationManager.reschedule(for: item)
        } else {
            let item = TodoItem(title: trimmed, reminderDate: reminder, list: list,
                                priority: priority, repeatRule: repeatRule)
            context.insert(item)
            NotificationManager.schedule(for: item)
        }
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
}
