import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            RoutineView()
                .tabItem { Label("Tonight", systemImage: "moon.fill") }
            MorningCheckInView()
                .tabItem { Label("Check-in", systemImage: "sun.max.fill") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}
