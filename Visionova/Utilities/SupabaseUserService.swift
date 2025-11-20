import Foundation

private struct SupabaseUserPayload: Codable {
    let id: UUID
    let email: String

    enum CodingKeys: String, CodingKey {
        case id
        case email
    }
}

/// Handles inserting/upserting the authenticated user record inside the public.users table.
final class SupabaseUserService {
    private let config = SupabaseConfiguration()
    private let encoder = JSONEncoder()

    func ensureUserExists(session: SupabaseSession) async throws {
        let url = config.baseURL.appending(path: "/rest/v1/users")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("resolution=merge-duplicates", forHTTPHeaderField: "Prefer")
        let payload = SupabaseUserPayload(
            id: session.user.id,
            email: session.user.email
        )
        request.httpBody = try encoder.encode(payload)
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw UserSyncError.failed
        }
    }

    enum UserSyncError: LocalizedError {
        case failed
        var errorDescription: String? { "Unable to sync user profile with Supabase." }
    }
}

