import Foundation
import FamilyControls
import ManagedSettings

@Observable
final class ScreenTimeManager {
    var isAuthorized = false
    var isShieldActive = false
    private let store = ManagedSettingsStore()

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = true
        } catch {
            isAuthorized = false
        }
    }

    func applyShield(selection: FamilyActivitySelection) {
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomainCategories = .specific(selection.categoryTokens)
        isShieldActive = true
    }

    func removeShield() {
        store.shield.applicationCategories = nil
        store.shield.webDomainCategories = nil
        isShieldActive = false
    }
}
