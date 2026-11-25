import SwiftUI
import SwiftData
import WidgetKit

// The main screen: today's tasks grouped into sections, with add / edit / complete / delete.
struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TodoItem.createdAt, order: .forward) private var items: [TodoItem]

    @State private var showingAdd = false
    @State private var editing: TodoItem?

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add task")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEditTaskView()
            }
            .sheet(item: $editing) { item in
                AddEditTaskView(editing: item)
            }
        }
        .tint(AppTheme.accent)
        .task {
            if ProcessInfo.processInfo.environment["PINGLET_SEED"] == "1" {
                if items.isEmpty { SampleData.seed(into: context) }
            } else {
                NotificationManager.requestAuthorization()
            }
        }
    }

    private var taskList: some View {
        List {
            ForEach(Bucket.allCases, id: \.self) { bucket in
                let tasks = sortedTasks(in: bucket)
                if !tasks.isEmpty {
                    Section(bucket.title) {
                        ForEach(tasks) { item in
                            TaskRowView(item: item) { toggle(item) }
                                .contentShape(Rectangle())
                                .onTapGesture { editing = item }
                        }
                        .onDelete { offsets in delete(tasks, at: offsets) }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("All clear", systemImage: "checkmark.circle")
        } description: {
            Text("Tap + to add your first task.")
        }
    }

    // Tasks in a bucket, soonest reminder first (no-date tasks last).
    private func sortedTasks(in bucket: Bucket) -> [TodoItem] {
        items
            .filter { bucket.contains($0) }
            .sorted { a, b in
                if a.priority.rawValue != b.priority.rawValue {
                    return a.priority.rawValue > b.priority.rawValue   // higher priority first
                }
                return (a.reminderDate ?? .distantFuture) < (b.reminderDate ?? .distantFuture)
            }
    }

    private func toggle(_ item: TodoItem) {
        item.isDone.toggle()
        if item.isDone {
            NotificationManager.cancel(item)
        } else {
            NotificationManager.schedule(for: item)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func delete(_ tasks: [TodoItem], at offsets: IndexSet) {
        for index in offsets {
            let item = tasks[index]
            NotificationManager.cancel(item)
            context.delete(item)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}

#Preview {
    TodayView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}
