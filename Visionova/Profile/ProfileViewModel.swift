import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var demographics: HealthDemographics?
    @Published var statusMessage: String?

    private let sessionStore: SessionStore
    private let healthKitManager: HealthKitManager

    init(sessionStore: SessionStore, healthKitManager: HealthKitManager) {
        self.sessionStore = sessionStore
        self.healthKitManager = healthKitManager
    }

    var email: String {
        sessionStore.session?.email ?? "Unknown"
    }

    func importHealthKit() async {
        do {
            let _ = try await healthKitManager.requestPermissions()
            demographics = try await healthKitManager.readBasicDemographics()
            statusMessage = "Health data synced"
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    func logout() async {
        await sessionStore.signOut()
    }
}
