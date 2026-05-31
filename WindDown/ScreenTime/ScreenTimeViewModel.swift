import Foundation
import Observation
import FamilyControls

@Observable
final class ScreenTimeViewModel {
    var appState: AppState
    var manager: ScreenTimeManager
    var activitySelection = FamilyActivitySelection()
    var showActivityPicker = false

    init(appState: AppState, manager: ScreenTimeManager = ScreenTimeManager()) {
        self.appState = appState
        self.manager = manager
    }

    func requestAuth() async {
        await manager.requestAuthorization()
    }

    func applyShield() {
        manager.applyShield(selection: activitySelection)
    }

    func removeShield() {
        manager.removeShield()
    }
}
