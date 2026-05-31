import SwiftUI
import SwiftData

struct MorningCheckInView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState
    @State private var viewModel: CheckInViewModel?
    @State private var mood = 3
    @State private var energy = 3
    @State private var note = ""
    @State private var showInsights = false
    @State private var saved = false

    var body: some View {
        NavigationStack {
            Form {
                Section("How did you sleep?") {
                    LabeledContent("Mood") {
                        Picker("Mood", selection: $mood) {
                            ForEach(1...5, id: \.self) { Text("\($0)") }
                        }
                        .pickerStyle(.segmented)
                    }
                    LabeledContent("Energy") {
                        Picker("Energy", selection: $energy) {
                            ForEach(1...5, id: \.self) { Text("\($0)") }
                        }
                        .pickerStyle(.segmented)
                    }
                    TextField("Optional note", text: $note, axis: .vertical)
                        .lineLimit(3)
                }

                Section {
                    Button(saved ? "Saved" : "Save Check-in") {
                        viewModel?.saveCheckIn(mood: mood, energy: energy, note: note, context: context)
                        saved = true
                    }
                    .disabled(saved)

                    if saved {
                        Button("View Insights") { showInsights = true }
                    }
                }
            }
            .navigationTitle("Morning Check-in")
            .navigationDestination(isPresented: $showInsights) {
                InsightsView()
            }
            .onAppear {
                if viewModel == nil { viewModel = CheckInViewModel(appState: appState) }
                saved = appState.lastCheckIn.map {
                    Calendar.current.isDateInToday($0.date)
                } ?? false
            }
        }
    }
}
