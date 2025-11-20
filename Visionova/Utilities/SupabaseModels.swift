import Foundation

struct SupabaseScanRecord: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let imageUrl: String?
    let prediction: String
    let confidence: Double
    let createdAt: Date

    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case imageUrl = "image_url"
        case prediction
        case confidence
        case createdAt = "created_at"
    }
}

enum SupabaseTable {
    case scans(userId: UUID)

    func urlRequest(limit: Int = 50) throws -> URLRequest {
        let config = SupabaseConfiguration()
        switch self {
        case .scans(let userId):
            var components = URLComponents(url: config.baseURL.appending(path: "/rest/v1/scans"), resolvingAgainstBaseURL: false)
            components?.queryItems = [
                URLQueryItem(name: "user_id", value: "eq.\(userId.uuidString)"),
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
            guard let url = components?.url else { throw URLError(.badURL) }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(config.anonKey)", forHTTPHeaderField: "Authorization")
            request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
            return request
        }
    }
}
