import LocalAuthentication
import Foundation

struct LocalUserSession: Codable, Identifiable {
    let id: UUID
    let email: String
}

final class LocalAuthManager {
    func authenticate() async throws -> LocalUserSession {
        let context = LAContext()
        var error: NSError?
        
        let reason = "Unlock Visionova with your device credentials"
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            return try await withCheckedThrowingContinuation { continuation in
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, evalError in
                    if success {
                        let userEmail = UserDefaults.standard.string(forKey: "local_user_email") ?? "user@visionova.app"
                        continuation.resume(returning: LocalUserSession(id: UUID(), email: userEmail))
                    } else {
                        continuation.resume(throwing: evalError ?? AuthError.authenticationFailed)
                    }
                }
            }
        } else {
            // Simulator or device without passcode
            let userEmail = UserDefaults.standard.string(forKey: "local_user_email") ?? "user@visionova.app"
            return LocalUserSession(id: UUID(), email: userEmail)
        }
    }
    
    enum AuthError: LocalizedError {
        case authenticationFailed
        var errorDescription: String? {
            return "Local authentication failed."
        }
    }
}
