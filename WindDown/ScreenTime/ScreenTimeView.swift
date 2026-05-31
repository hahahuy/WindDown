import SwiftUI

#if !targetEnvironment(simulator)
import FamilyControls
#endif

struct ScreenTimeView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: ScreenTimeViewModel?

    var body: some View {
        Form {
            if viewModel?.manager.isAuthorized == false {
                Section {
                    Text("Screen Time permission is required to block distracting apps after bedtime.")
                        .foregroundStyle(.secondary)
#if !targetEnvironment(simulator)
                    Button("Grant Permission") {
                        Task { await viewModel?.requestAuth() }
                    }
#else
                    Text("Not available in simulator.")
                        .foregroundStyle(.secondary)
                        .font(.caption)
#endif
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
#if !targetEnvironment(simulator)
                    Button("Choose apps to block") {
                        viewModel?.showActivityPicker = true
                    }
#endif
                }
            }
        }
        .navigationTitle("Screen Time")
#if !targetEnvironment(simulator)
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
#endif
        .onAppear {
            if viewModel == nil { viewModel = ScreenTimeViewModel(appState: appState) }
        }
    }
}
