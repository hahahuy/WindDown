import XCTest
@testable import WindDown

final class OpenRouterServiceTests: XCTestCase {
    func test_buildPrompt_includesCheckInData() {
        let entry = CheckInEntry(mood: 4, energy: 3, note: "Felt tired")
        let prompt = OpenRouterService.buildPrompt(entries: [entry], records: [])
        XCTAssertTrue(prompt.contains("mood: 4"))
        XCTAssertTrue(prompt.contains("energy: 3"))
        XCTAssertTrue(prompt.contains("Felt tired"))
    }

    func test_buildPrompt_includesSleepRecord() {
        let record = SleepRecord(date: Date(), targetBedtime: Date(), routineScore: 0.8)
        let prompt = OpenRouterService.buildPrompt(entries: [], records: [record])
        XCTAssertTrue(prompt.contains("0.8"))
    }

    func test_parseResponse_extractsContent() throws {
        let json = """
        {"choices":[{"message":{"content":"Sleep well!"}}]}
        """
        let data = json.data(using: .utf8)!
        let result = try OpenRouterService.parseContent(from: data)
        XCTAssertEqual(result, "Sleep well!")
    }

    func test_parseResponse_throwsOnMissingContent() {
        let json = """
        {"choices":[]}
        """
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try OpenRouterService.parseContent(from: data))
    }
}
