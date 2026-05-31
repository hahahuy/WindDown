import SwiftUI
import SwiftData

struct RoutineView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState
    @State private var viewModel: RoutineViewModel?
    @State private var showTemplatePicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let vm = viewModel {
                    Text(vm.timeUntilBedtime)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                }

                if appState.todayRoutine.isEmpty {
                    ContentUnavailableView(
                        "No routine yet",
                        systemImage: "moon.zzz",
                        description: Text("Pick a template to get started")
                    )
                } else {
                    List(appState.todayRoutine) { item in
                        RoutineItemRow(item: item, bedtime: appState.bedtime) {
                            viewModel?.toggleComplete(item, context: context)
                        }
                    }
                }
            }
            .navigationTitle("Tonight")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Template") { showTemplatePicker = true }
                }
            }
            .sheet(isPresented: $showTemplatePicker) {
                TemplatePickerView { showTemplatePicker = false }
            }
            .onAppear {
                if viewModel == nil { viewModel = RoutineViewModel(appState: appState) }
            }
        }
    }
}
