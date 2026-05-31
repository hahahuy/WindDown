import SwiftUI
import SwiftData

struct InsightsView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState
    @State private var viewModel: CheckInViewModel?
    @Query(sort: \CheckInEntry.date, order: .reverse) private var entries: [CheckInEntry]
    @Query(sort: \SleepRecord.date, order: .reverse) private var records: [SleepRecord]

    private var latestEntry: CheckInEntry? { entries.first }

    var body: some View {
        List {
            if let entry = latestEntry {
                Section("Today's Insight") {
                    if let insight = entry.aiInsight {
                        Text(insight)
                    } else if viewModel?.isLoadingInsight == true {
                        ProgressView("Loading insight...")
                    } else {
                        Button(viewModel?.insightError ?? "Get Insight") {
                            Task {
                                await viewModel?.fetchInsight(
                                    entry: entry,
                                    recentEntries: Array(entries.prefix(7)),
                                    records: Array(records.prefix(7)),
                                    context: context
                                )
                            }
                        }
                    }
                }
            }

            Section("Recent Check-ins") {
                ForEach(entries.prefix(7)) { entry in
                    HStack {
                        Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                        Spacer()
                        Text("Mood \(entry.mood) · Energy \(entry.energy)")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Insights")
        .onAppear {
            if viewModel == nil { viewModel = CheckInViewModel(appState: appState) }
        }
    }
}
