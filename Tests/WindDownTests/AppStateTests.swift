import XCTest
@testable import WindDown

final class AppStateTests: XCTestCase {
    func test_streakIncrements_whenAllItemsCompleted() {
        let state = AppState()
        let ids: Set<UUID> = [UUID(), UUID()]
        state.completedItems = ids
        state.incrementStreakIfComplete(totalItems: ids.count)
        XCTAssertEqual(state.streak, 1)
    }

    func test_streakDoesNotIncrement_whenItemsMissed() {
        let state = AppState()
        state.completedItems = [UUID()]
        state.incrementStreakIfComplete(totalItems: 3)
        XCTAssertEqual(state.streak, 0)
    }

    func test_resetClearsCompletedItems() {
        let state = AppState()
        state.completedItems = [UUID(), UUID()]
        state.resetForNewNight(totalItems: 2)
        XCTAssertTrue(state.completedItems.isEmpty)
    }
}
