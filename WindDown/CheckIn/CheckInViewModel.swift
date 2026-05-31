import Foundation
import Observation
import SwiftData

@Observable
final class CheckInViewModel {
    var appState: AppState
    var isLoadingInsight = false
    var insightError: String?
    private let openRouter: OpenRouterService

    init(appState: AppState, apiKey: String = "") {
        self.appState = appState
        self.openRouter = OpenRouterService(apiKey: apiKey)
    }

    func saveCheckIn(mood: Int, energy: Int, note: String?, context: ModelContext) {
        let entry = CheckInEntry(mood: mood, energy: energy, note: note.flatMap { $0.isEmpty ? nil : $0 })
        context.insert(entry)
        try? context.save()
        appState.lastCheckIn = entry
    }

    func fetchInsight(entry: CheckInEntry, recentEntries: [CheckInEntry], records: [SleepRecord], context: ModelContext) async {
        guard entry.aiInsight == nil else { return }
        isLoadingInsight = true
        insightError = nil
        do {
            let insight = try await openRouter.fetchInsight(entries: recentEntries, records: records)
            entry.aiInsight = insight
            try? context.save()
        } catch {
            insightError = "Couldn't load insight — tap to retry"
        }
        isLoadingInsight = false
    }
}
