import Foundation
import Observation

#if !targetEnvironment(simulator)
import FamilyControls
import ManagedSettings
#endif

@Observable
final class ScreenTimeViewModel {
    var appState: AppState
    var manager: ScreenTimeManager
    var showActivityPicker = false

#if !targetEnvironment(simulator)
    var activitySelection = FamilyActivitySelection()
#endif

    init(appState: AppState, manager: ScreenTimeManager = ScreenTimeManager()) {
        self.appState = appState
        self.manager = manager
    }

    func requestAuth() async {
        await manager.requestAuthorization()
    }

    func applyShield() {
#if !targetEnvironment(simulator)
        manager.applyShield(selection: activitySelection)
#endif
    }

    func removeShield() {
        manager.removeShield()
    }
}
