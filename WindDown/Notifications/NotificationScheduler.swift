import Foundation
import UserNotifications

final class NotificationScheduler {
    static let categoryIdentifier = "WINDDOWN_ROUTINE"

    static func notificationDate(for item: RoutineItem, bedtime: Date) -> Date {
        bedtime.addingTimeInterval(Double(-item.minutesBefore) * 60)
    }

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(options: [.alert, .sound])
        return granted ?? false
    }

    func scheduleAll(items: [RoutineItem], bedtime: Date) async {
        let center = UNUserNotificationCenter.current()
        await center.removeAllPendingNotificationRequests()

        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        for item in items where !item.isCompleted {
            let fireDate = Self.notificationDate(for: item, bedtime: bedtime)
            guard fireDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = "WindDown"
            content.body = item.title
            content.sound = .default
            content.categoryIdentifier = Self.categoryIdentifier

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: item.id.uuidString,
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    func cancel(itemId: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [itemId.uuidString])
    }
}
