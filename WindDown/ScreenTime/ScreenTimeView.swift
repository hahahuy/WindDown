import SwiftUI
import FamilyControls

struct ScreenTimeView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: ScreenTimeViewModel?

    var body: some View {
        Form {
            if viewModel?.manager.isAuthorized == false {
                Section {
                    Text("Screen Time permission is required to block distracting apps after bedtime.")
                        .foregroundStyle(.secondary)
                    Button("Grant Permission") {
                        Task { await viewModel?.requestAuth() }
                    }
                }
            } else {
                Section("App Blocking") {
                    Toggle("Block apps after bedtime", isOn: Binding(
                        get: { viewModel?.manager.isShieldActive ?? false },
                        set: { active in
                            if active { viewModel?.applyShield() }
                            else { viewModel?.removeShield() }
                        }
                    ))

                    Button("Choose apps to block") {
                        viewModel?.showActivityPicker = true
                    }
                }
            }
        }
        .navigationTitle("Screen Time")
        .familyActivityPicker(
            isPresented: Binding(
                get: { viewModel?.showActivityPicker ?? false },
                set: { viewModel?.showActivityPicker = $0 }
            ),
            selection: Binding(
                get: { viewModel?.activitySelection ?? FamilyActivitySelection() },
                set: { viewModel?.activitySelection = $0 }
            )
        )
        .onAppear {
            if viewModel == nil { viewModel = ScreenTimeViewModel(appState: appState) }
        }
    }
}
