import Foundation
import Combine

/// Observable session state used across the app.
final class SessionStore: ObservableObject {
    @Published private(set) var session: SupabaseSession?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let authManager: SupabaseAuthManager

    init(authManager: SupabaseAuthManager) {
        self.authManager = authManager
    }

    var isAuthenticated: Bool {
        session != nil
    }

    @MainActor
    func signIn(email: String, password: String) async {
        await authenticate { [self] in
            try await self.authManager.signIn(email: email, password: password)
        }
    }

    @MainActor
    func signUp(email: String, password: String) async {
        await authenticate { [self] in
            try await self.authManager.signUp(email: email, password: password)
        }
    }

    @MainActor
    private func authenticate(_ action: @escaping () async throws -> SupabaseSession) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let session = try await action()
            self.session = session
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func signOut() async {
        guard let token = session?.accessToken else { return }
        isLoading = true
        defer {
            isLoading = false
            session = nil
        }
        do {
            try await authManager.signOut(accessToken: token)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
