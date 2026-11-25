# Architecture

Pinglet is a small, local-only iOS app plus a home-screen widget. The two targets share a single
on-device database and a small amount of model code.

## Targets

| Target | What it is | Bundle id |
|---|---|---|
| `Pinglet` | The app (SwiftUI) | `com.samyakgoel.Pinglet` |
| `PingletWidgetExtension` | The home-screen widget (WidgetKit) | `com.samyakgoel.Pinglet.widget` |

Both are defined in [`project.yml`](../project.yml) and generated into `Pinglet.xcodeproj` by
XcodeGen, so the project is readable, diffable text.

## Shared code

Everything in [`Shared/`](../Shared) is compiled into **both** targets:

- **`TodoItem`** — the `@Model` task: title, done flag, due/reminder dates, list, priority, repeat rule.
- **`TaskList`**, **`Priority`**, **`RepeatRule`** — typed enums (with colours / symbols) stored as
  primitive columns on `TodoItem` and exposed through computed properties.
- **`Bucket`** — the grouping logic for the Today screen (Overdue / Today / Upcoming / No date / Completed).
- **`AppGroup`** — the shared container id, `group.com.samyakgoel.Pinglet`.
- **`SharedModelContainer`** — builds one `ModelContainer` backed by the App Group container, so the
  app and the widget read and write the same store. It falls back to a local store if the App Group
  is unavailable, so the app always runs.
- **`NotificationManager`** — schedules local notifications, including repeats.
- **`ToggleTaskIntent`** — the `AppIntent` behind the interactive widget.

## How the widget stays in sync

```
            writes                         reloadAllTimelines()
  App  ───────────────▶  App Group store  ◀───────────────  Widget
   ▲                     (SwiftData)                           │
   │                                                           │
   └──────────── ToggleTaskIntent (tap on widget) ─────────────┘
```

- The app and the widget both open the **same** SwiftData store via `SharedModelContainer`.
- When the app changes a task (complete, add, edit, delete) it calls
  `WidgetCenter.shared.reloadAllTimelines()` so the widget refreshes.
- When you tap a task's circle **on the widget**, `ToggleTaskIntent` runs in the widget process,
  toggles the task in the shared store, updates its notification, and reloads the timelines — all
  without launching the app.

## Reminders

`NotificationManager.schedule(for:)` keys each notification to the task's `id`:

- **Once** — a non-repeating `UNCalendarNotificationTrigger` at the exact date.
- **Daily / Weekly** — a repeating trigger on the hour/minute (and weekday).
- **Weekdays** — five repeating triggers, Monday–Friday, with per-weekday ids.

Completing or deleting a task cancels its pending notification(s); editing reschedules them.

## Why XcodeGen

`Pinglet.xcodeproj` is **generated** and git-ignored. The project's real definition is `project.yml`,
so there are no opaque, merge-hostile project files in version control. After cloning or editing
`project.yml`, run `xcodegen generate`.
