import SwiftUI
import SwiftData

struct TemplatePickerView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState
    @Query private var templates: [RoutineTemplate]
    @State private var viewModel: RoutineViewModel?
    let onSelect: () -> Void

    var body: some View {
        NavigationStack {
            List(allTemplates) { template in
                Button(template.name) {
                    viewModel?.loadRoutine(template: template, context: context)
                    onSelect()
                }
            }
            .navigationTitle("Choose Template")
            .onAppear {
                if viewModel == nil { viewModel = RoutineViewModel(appState: appState) }
                seedBuiltInTemplatesIfNeeded()
            }
        }
    }

    private var allTemplates: [RoutineTemplate] {
        templates.isEmpty ? RoutineTemplate.builtIn : templates
    }

    private func seedBuiltInTemplatesIfNeeded() {
        guard templates.filter({ $0.isBuiltIn }).isEmpty else { return }
        RoutineTemplate.builtIn.forEach { context.insert($0) }
        try? context.save()
    }
}
