import Foundation

/// Represents a minimal subset of the Supabase session payload.
struct SupabaseSession: Codable, Identifiable {
    struct User: Codable {
        let id: UUID
        let email: String
    }

    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let user: User

    var id: UUID { user.id }
}

/// Configuration values needed to call Supabase Auth REST endpoints.
struct SupabaseConfiguration {
    let baseURL: URL
    let anonKey: String

    init() {
        let info = Bundle.main.infoDictionary ?? [:]
        let urlString = info["SUPABASE_URL"] as? String ?? "https://ejotcehtmakiljulhtzw.supabase.co"
        let keyString = info["SUPABASE_ANON_KEY"] as? String ?? "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVqb3RjZWh0bWFraWxqdWxodHp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM2MjI3MzcsImV4cCI6MjA3OTE5ODczN30.sji9ENOfAh249kmic6FhZnqevx42_DT4alkEaEzJAh8"
        guard let url = URL(string: urlString) else {
            fatalError("Supabase URL missing. Set SUPABASE_URL in Info.plist user-defined section.")
        }
        self.baseURL = url
        self.anonKey = keyString
    }
}

/// Handles sign-in, sign-up and sign-out flows via Supabase Auth REST APIs.
final class SupabaseAuthManager {
    private let configuration = SupabaseConfiguration()
    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    func signIn(email: String, password: String) async throws -> SupabaseSession {
        let endpoint = configuration.baseURL.appending(path: "/auth/v1/token")
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "grant_type", value: "password")]
        guard let url = components?.url else { throw AuthError.invalidURL }
        let payload = ["email": email, "password": password]
        return try await performRequest(url: url, payload: payload)
    }

    func signUp(email: String, password: String) async throws -> SupabaseSession {
        let url = configuration.baseURL.appending(path: "/auth/v1/signup")
        let payload = ["email": email, "password": password]
        return try await performRequest(url: url, payload: payload)
    }

    func signOut(accessToken: String) async throws {
        var request = URLRequest(url: configuration.baseURL.appending(path: "/auth/v1/logout"))
        request.httpMethod = "POST"
        request.setValue(configuration.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        _ = try await URLSession.shared.data(for: request)
    }

    private func performRequest(url: URL, payload: [String: Any]) async throws -> SupabaseSession {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(configuration.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown"
            throw AuthError.server(message)
        }
        let session = try jsonDecoder.decode(SupabaseSession.self, from: data)
        return session
    }

    enum AuthError: LocalizedError {
        case invalidURL
        case server(String)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Supabase URL is invalid."
            case .server(let message):
                return "Supabase error: \(message)"
            }
        }
    }
}
