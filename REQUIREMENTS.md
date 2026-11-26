# Pinglet — Requirements

Status key: `[ ]` not started · `[~]` in progress · `[x]` done · `[?]` needs decision

> This is the **what**, not the **how**. The ordered build plan lives in [POA.md](POA.md).
> Anything marked `[?]` is a decision to confirm before it's built.

---

## 1. Who & why
- **User:** just me, on my own iPhone. No other users, no sharing, no accounts.
- **Why:** capture tasks fast, get reminded at the right time, tick things off from
  the home screen without opening the app.
- **Privacy:** all data stays on the device. No network calls, no analytics, no server.

## 2. Platforms & constraints
- iPhone only (iPad later, maybe). iOS **26.0+** — required for the **Liquid Glass** UI and its
  APIs (also covers SwiftData + interactive widgets). My iPhone must be on iOS 26.
- **Lightweight:** Apple frameworks only (no third-party libraries), few screens, small footprint.
- Must run installed from a **free Apple ID** at first (7-day expiry — data survives re-install).
- Portrait orientation is enough for v1.

## 3. Version 1 — core features (MUST)
- **[ ] Task list** — see all tasks, newest/soonest first.
- **[ ] Add task** — title (required). Keep the add flow to one tap + type.
- **[ ] Edit task** — change title, due date, reminder.
- **[ ] Complete task** — tap to mark done; done tasks visually distinct (not deleted immediately).
- **[ ] Delete task** — swipe to delete.
- **[ ] Due date + reminder time** — pick a date/time; schedule a local notification.
- **[ ] Notification fires** — alert shows at the set time even if the app is closed.
- **[ ] Widget (small + medium)** — shows the next few tasks.
- **[ ] Interactive widget** — tap a task's circle on the widget to mark it done, no app launch.
- **[ ] Shared storage** — app and widget show the same tasks within a second or two of a change.

## 4. Version 1 — nice to have (SHOULD, only if core is solid)
- **[?] Lists / categories** — e.g. Work, Personal. Decision: tags vs. separate lists?
- **[?] Priority** — low/med/high, affects sort order.
- **[?] Repeating reminders** — daily / weekdays / weekly. (Notifications support this but it adds complexity.)
- **[ ] Empty state** — friendly message when there are no tasks.

## 5. Later / out of scope for v1 (WON'T, yet)
- Lock-screen widget / Live Activities.
- iCloud sync across devices (needs the paid program + CloudKit).
- Sub-tasks, attachments, notes, search, themes.
- iPad / Mac layouts.

## 6. Data model (draft — confirm before coding)
A single `Task` (we may rename to `TodoItem` to avoid clashing with Swift's `Task` concurrency type):
| Field | Type | Notes |
|---|---|---|
| `id` | UUID | stable id, used by notifications + widget |
| `title` | String | required |
| `isDone` | Bool | default false |
| `dueDate` | Date? | optional |
| `reminderDate` | Date? | optional; if set, schedules a notification |
| `createdAt` | Date | default now, for sorting |
| `priority` | enum? | `[?]` only if we add priority |
| `listName` | String? | `[?]` only if we add lists |

**Decision `[?]`:** rename `Task` → `TodoItem`? (Recommended yes — avoids confusion with Swift concurrency.)

## 7. Acceptance checks (how we know v1 is "done")
- [ ] Add a task with a reminder 2 minutes out → notification fires with app closed.
- [ ] Complete a task in the app → it shows completed in the widget within ~seconds.
- [ ] Complete a task from the widget → it shows completed in the app.
- [ ] Force-quit the app, reopen → all tasks still there.
- [ ] Delete a task → its pending notification is cancelled (no ghost alert).
- [ ] App re-installed after 7-day expiry → data still present.

## 8. Open decisions to resolve (tracked)
1. `[?]` Rename `Task` → `TodoItem`?
2. `[?]` Lists/categories in v1 or later?
3. `[?]` Priority in v1 or later?
4. `[?]` Repeating reminders in v1 or later?
5. `[?]` Bundle identifier — proposed `com.samyakgoel.Pinglet` (confirm your preferred prefix).
