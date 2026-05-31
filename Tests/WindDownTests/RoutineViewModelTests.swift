import XCTest
@testable import WindDown

final class RoutineViewModelTests: XCTestCase {
    func test_buildRoutine_producesCorrectItemCount() {
        let template = RoutineTemplate(
            name: "Test",
            items: [
                TemplateItem(title: "A", minutesBefore: 30),
                TemplateItem(title: "B", minutesBefore: 15),
                TemplateItem(title: "C", minutesBefore: 0),
            ]
        )
        let bedtime = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date())!
        let items = RoutineViewModel.buildItems(from: template, bedtime: bedtime, date: Date())
        XCTAssertEqual(items.count, 3)
    }

    func test_buildRoutine_setsCorrectMinutesBefore() {
        let template = RoutineTemplate(
            name: "Test",
            items: [TemplateItem(title: "Brush teeth", minutesBefore: 30)]
        )
        let bedtime = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date())!
        let items = RoutineViewModel.buildItems(from: template, bedtime: bedtime, date: Date())
        XCTAssertEqual(items.first?.minutesBefore, 30)
        XCTAssertEqual(items.first?.title, "Brush teeth")
    }

    func test_buildRoutine_setsTemplateId() {
        let template = RoutineTemplate(name: "Test", items: [TemplateItem(title: "A", minutesBefore: 10)])
        let bedtime = Date()
        let items = RoutineViewModel.buildItems(from: template, bedtime: bedtime, date: Date())
        XCTAssertEqual(items.first?.templateId, template.id)
    }
}
