import Foundation
import Combine

/// Observable session state used across the app natively via LocalAuth.
final class SessionStore: ObservableObject {
    @Published private(set) var session: LocalUserSession?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let authManager: LocalAuthManager

    init(authManager: LocalAuthManager) {
        self.authManager = authManager
    }

    var isAuthenticated: Bool {
        session != nil
    }

    @MainActor
    func signIn() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let session = try await authManager.authenticate()
            self.session = session
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func signOut() async {
        isLoading = true
        defer {
            isLoading = false
            session = nil
        }
        // Local auth doesn't really "sign out" remotely, just clear the local session
    }
}
