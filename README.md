# WindDown

A smart bedtime routine app for iOS. You set a target bedtime; WindDown reverse-engineers a nightly checklist from that time, sends adaptive notifications as each window approaches, tracks your consistency via Apple Health, and surfaces AI-generated insights from your morning mood and energy logs.

## Features

- **Nightly routine checklist** — built from a template and your target bedtime, with each item scheduled at the right time before sleep
- **Adaptive notifications** — local notifications that reschedule dynamically as you complete items
- **Routine templates** — choose from Night Owl Reform, Busy Parent, or Athlete Recovery
- **Morning check-in** — log mood and energy each morning; the app correlates your routine consistency with how you feel
- **AI insights** — powered by OpenRouter (free tier), surfaces patterns from your last 7 days of check-ins and sleep data
- **Apple Health integration** — reads sleep analysis to compare actual vs. target bedtime
- **Screen Time blocking** — optionally blocks distracting apps after bedtime using Apple's FamilyControls framework (physical device only)
- **Streak tracking** — counts consecutive nights of full routine completion

## Architecture

WindDown uses **MVVM** (Model–View–ViewModel), not traditional MVC. ViewModels replace Controllers: they hold presentation logic and mediate between the data layer and the UI, while Views remain declarative and free of business logic.

A shared `AppState` object holds cross-cutting state (bedtime, tonight's routine, streak, last check-in) and is injected at the root via SwiftUI's `.environment()`. Feature ViewModels read and write AppState rather than talking to each other directly.

---

### Model

Persistent data layer using **SwiftData**.

| Model | Responsibility |
|-------|---------------|
| `RoutineItem` | A single checklist item for one night — title, `minutesBefore` offset, completion state, date |
| `RoutineTemplate` | A named set of `TemplateItem` steps (e.g. "Night Owl Reform") with `minutesBefore` offsets |
| `CheckInEntry` | One morning's mood (1–5), energy (1–5), optional note, and cached AI insight |
| `SleepRecord` | Nightly record of actual bedtime (from HealthKit), target bedtime, and routine completion score |

`TemplateItem` is a `Codable` value type embedded inside `RoutineTemplate` — not a separate `@Model`.

`AppState` is an `@Observable` class that holds in-memory cross-cutting state and persists `bedtime`, `wakeTime`, and `streak` to `UserDefaults`.

---

### View

SwiftUI views organised by feature. Views read from `AppState` and their feature ViewModel; they never contain business logic.

```
WindDown/
├── App/
│   ├── WindDownApp.swift       — @main entry point, modelContainer, AppState injection
│   ├── ContentView.swift       — root view
│   └── MainTabView.swift       — 3-tab navigation (Tonight / Check-in / Settings)
├── Routine/
│   ├── RoutineView.swift       — tonight's checklist + countdown
│   ├── RoutineItemRow.swift    — single checklist row with scheduled time
│   └── TemplatePickerView.swift — sheet to pick or change template
├── CheckIn/
│   ├── MorningCheckInView.swift — mood/energy/note form
│   └── InsightsView.swift      — recent check-ins + AI insight
├── ScreenTime/
│   └── ScreenTimeView.swift    — permission request + app blocking toggle
└── Settings/
    └── SettingsView.swift      — bedtime, wake time, Health, notifications, streak
```

---

### ViewModel

Each feature folder owns one ViewModel. ViewModels are `@Observable` classes that take `AppState` as a dependency.

| ViewModel | Responsibility |
|-----------|---------------|
| `RoutineViewModel` | Builds tonight's `[RoutineItem]` from a template + bedtime; handles item completion and notification rescheduling |
| `CheckInViewModel` | Saves morning check-in entries; calls `OpenRouterService` to fetch and cache AI insights |
| `ScreenTimeViewModel` | Manages FamilyControls authorisation and shield state via `ScreenTimeManager` |

---

### Services

Plain classes injected into ViewModels. No UI dependencies.

| Service | Responsibility |
|---------|---------------|
| `NotificationScheduler` | Schedules and cancels `UNUserNotificationCenter` notifications based on routine item times |
| `HealthKitService` | Requests sleep analysis permission; fetches last night's sleep interval; writes `SleepRecord` |
| `OpenRouterService` | Sends last 7 days of check-in and sleep data to OpenRouter chat completions; parses and returns the insight string |
| `ScreenTimeManager` | Wraps `FamilyControls` + `ManagedSettings`; applies/removes app category shields (device only — stubbed in simulator) |

---

## Data Flow

```
User sets bedtime
    → AppState.setBedtime()
    → RoutineViewModel.loadRoutine(template:)
        → builds [RoutineItem] from template offsets
        → inserts into SwiftData
        → NotificationScheduler.scheduleAll()

User taps item complete
    → RoutineViewModel.toggleComplete()
        → AppState.markComplete()
        → NotificationScheduler.cancel(itemId:)

Morning launch
    → HealthKitService.writeSleepRecord()
        → fetches HKSleepAnalysis
        → writes SleepRecord to SwiftData

User taps "Get Insight"
    → CheckInViewModel.fetchInsight()
        → OpenRouterService.fetchInsight(entries:records:)
        → caches result in CheckInEntry.aiInsight
```

---

## CI/CD

GitHub Actions on push to `master`:

1. Install XcodeGen → generate `.xcodeproj`
2. `xcodebuild` for iOS Simulator (x86_64 + arm64, no code signing)
3. Zip `.app` bundle
4. Upload to [Appetize.io](https://appetize.io/app/wsto7vecvvzewjv6dwdga5h3zu) via REST API

Required secret: `APPETIZE_API_TOKEN`

## Tech Stack

- Swift 5.9 / SwiftUI / SwiftData
- iOS 17.0+
- XcodeGen (no committed `.xcodeproj`)
- UNUserNotificationCenter
- HealthKit
- FamilyControls + ManagedSettings (device only)
- OpenRouter API — `mistralai/mistral-7b-instruct:free`
