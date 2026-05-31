import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState
    @State private var bedtime: Date = Date()
    @State private var wakeTime: Date = Date()
    @State private var notificationsGranted: Bool? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section("Sleep Schedule") {
                    DatePicker("Bedtime", selection: $bedtime, displayedComponents: .hourAndMinute)
                        .onChange(of: bedtime) { _, new in appState.setBedtime(new) }
                    DatePicker("Wake time", selection: $wakeTime, displayedComponents: .hourAndMinute)
                        .onChange(of: wakeTime) { _, new in appState.setWakeTime(new) }
                }

                Section("Notifications") {
                    if notificationsGranted == false {
                        Label("Notifications disabled", systemImage: "bell.slash")
                            .foregroundStyle(.secondary)
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    } else {
                        Label("Notifications enabled", systemImage: "bell.fill")
                            .foregroundStyle(.green)
                    }
                }

                Section("Apple Health") {
                    Button("Connect Apple Health") {
                        Task {
                            let service = HealthKitService()
                            let granted = await service.requestPermission()
                            if granted {
                                await service.writeSleepRecord(
                                    targetBedtime: appState.bedtime,
                                    routineScore: Double(appState.completedItems.count) / Double(max(appState.todayRoutine.count, 1)),
                                    context: context
                                )
                            }
                        }
                    }
                }

                Section("Screen Time") {
                    NavigationLink("Screen Time Settings") {
                        ScreenTimeView()
                    }
                }

                Section("Stats") {
                    LabeledContent("Current streak", value: "\(appState.streak) nights")
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                bedtime = appState.bedtime
                wakeTime = appState.wakeTime
                Task {
                    let settings = await UNUserNotificationCenter.current().notificationSettings()
                    notificationsGranted = settings.authorizationStatus == .authorized
                }
            }
        }
    }
}
