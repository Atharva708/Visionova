import Foundation
import Combine

/// Global application state shared across the feature modules.
final class AppState: ObservableObject {
    enum MainTab: Int {
        case home
        case scan
        case history
    }

    @Published var selectedTab: MainTab = .home
    @Published var isProfilePresented = false

    @Published var sessionStore: SessionStore
    @Published var onboardingManager: OnboardingManager
    @Published var healthKitManager: HealthKitManager

    init(
        sessionStore: SessionStore = SessionStore(authManager: SupabaseAuthManager()),
        onboardingManager: OnboardingManager = OnboardingManager(),
        healthKitManager: HealthKitManager = HealthKitManager()
    ) {
        self.sessionStore = sessionStore
        self.onboardingManager = onboardingManager
        self.healthKitManager = healthKitManager
    }

    /// Determines if the floating button should be visible.
    var shouldShowFloatingButton: Bool {
        sessionStore.isAuthenticated && onboardingManager.isOnboardingComplete
    }
}
