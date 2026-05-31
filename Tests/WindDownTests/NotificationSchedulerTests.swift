import XCTest
@testable import WindDown

final class NotificationSchedulerTests: XCTestCase {
    func test_notificationTime_isCorrectOffset() {
        let bedtime = Calendar.current.date(
            bySettingHour: 23, minute: 0, second: 0, of: Date()
        )!
        let item = RoutineItem(title: "Brush teeth", minutesBefore: 30, date: Date(), templateId: UUID())
        let expected = bedtime.addingTimeInterval(-30 * 60)
        let result = NotificationScheduler.notificationDate(for: item, bedtime: bedtime)
        XCTAssertEqual(result, expected)
    }

    func test_notificationTime_atBedtime_whenMinutesBeforeIsZero() {
        let bedtime = Calendar.current.date(
            bySettingHour: 23, minute: 0, second: 0, of: Date()
        )!
        let item = RoutineItem(title: "Lights out", minutesBefore: 0, date: Date(), templateId: UUID())
        let result = NotificationScheduler.notificationDate(for: item, bedtime: bedtime)
        XCTAssertEqual(result, bedtime)
    }
}
