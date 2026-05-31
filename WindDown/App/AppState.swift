import Foundation
import Observation

@Observable
final class AppState {
    var bedtime: Date
    var wakeTime: Date
    var todayRoutine: [RoutineItem] = []
    var completedItems: Set<UUID> = []
    var streak: Int = 0
    var lastCheckIn: CheckInEntry?
    var activeTemplateId: UUID?

    init() {
        let defaults = UserDefaults.standard
        if let saved = defaults.object(forKey: "bedtime") as? Date {
            bedtime = saved
        } else {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 23; components.minute = 0
            bedtime = Calendar.current.date(from: components) ?? Date()
        }
        if let saved = defaults.object(forKey: "wakeTime") as? Date {
            wakeTime = saved
        } else {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 7; components.minute = 0
            wakeTime = Calendar.current.date(from: components) ?? Date()
        }
        streak = defaults.integer(forKey: "streak")
    }

    func setBedtime(_ date: Date) {
        bedtime = date
        UserDefaults.standard.set(date, forKey: "bedtime")
    }

    func setWakeTime(_ date: Date) {
        wakeTime = date
        UserDefaults.standard.set(date, forKey: "wakeTime")
    }

    func markComplete(_ id: UUID) {
        completedItems.insert(id)
    }

    func incrementStreakIfComplete(totalItems: Int) {
        guard totalItems > 0, completedItems.count >= totalItems else { return }
        streak += 1
        UserDefaults.standard.set(streak, forKey: "streak")
    }

    func resetForNewNight(totalItems: Int) {
        incrementStreakIfComplete(totalItems: totalItems)
        completedItems = []
    }
}
