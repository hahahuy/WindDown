import Foundation
import Observation

#if !targetEnvironment(simulator)
import FamilyControls
import ManagedSettings
#endif

@Observable
final class ScreenTimeManager {
    var isAuthorized = false
    var isShieldActive = false

#if !targetEnvironment(simulator)
    private let store = ManagedSettingsStore()
#endif

    func requestAuthorization() async {
#if targetEnvironment(simulator)
        isAuthorized = false
#else
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = true
        } catch {
            isAuthorized = false
        }
#endif
    }

#if !targetEnvironment(simulator)
    func applyShield(selection: FamilyActivitySelection) {
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomainCategories = .specific(selection.categoryTokens)
        isShieldActive = true
    }
#else
    func applyShield(selection: Any) {
        isShieldActive = false
    }
#endif

    func removeShield() {
#if !targetEnvironment(simulator)
        store.shield.applicationCategories = nil
        store.shield.webDomainCategories = nil
#endif
        isShieldActive = false
    }
}
