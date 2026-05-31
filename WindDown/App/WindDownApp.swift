import SwiftUI
import SwiftData

@main
struct WindDownApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .modelContainer(for: [RoutineItem.self, RoutineTemplate.self, CheckInEntry.self, SleepRecord.self])
    }
}
