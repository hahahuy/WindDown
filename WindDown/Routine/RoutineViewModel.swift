import Foundation
import Observation
import SwiftData

@Observable
final class RoutineViewModel {
    var appState: AppState
    private let scheduler: NotificationScheduler

    init(appState: AppState, scheduler: NotificationScheduler = NotificationScheduler()) {
        self.appState = appState
        self.scheduler = scheduler
    }

    static func buildItems(from template: RoutineTemplate, bedtime: Date, date: Date) -> [RoutineItem] {
        template.items.map { templateItem in
            RoutineItem(
                title: templateItem.title,
                minutesBefore: templateItem.minutesBefore,
                date: date,
                templateId: template.id
            )
        }
    }

    func loadRoutine(template: RoutineTemplate, context: ModelContext) {
        let today = Calendar.current.startOfDay(for: Date())
        let items = Self.buildItems(from: template, bedtime: appState.bedtime, date: today)
        items.forEach { context.insert($0) }
        appState.todayRoutine = items
        appState.activeTemplateId = template.id
        Task { await scheduler.scheduleAll(items: items, bedtime: appState.bedtime) }
    }

    func toggleComplete(_ item: RoutineItem, context: ModelContext) {
        item.isCompleted.toggle()
        if item.isCompleted {
            appState.markComplete(item.id)
            scheduler.cancel(itemId: item.id)
        } else {
            appState.completedItems.remove(item.id)
            Task { await scheduler.scheduleAll(items: appState.todayRoutine, bedtime: appState.bedtime) }
        }
        try? context.save()
    }

    var timeUntilBedtime: String {
        let interval = appState.bedtime.timeIntervalSinceNow
        guard interval > 0 else { return "Bedtime!" }
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m until bedtime" }
        return "\(minutes)m until bedtime"
    }
}
