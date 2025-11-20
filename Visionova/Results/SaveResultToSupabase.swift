import Foundation
import UIKit

struct SaveResultPayload: Codable {
    let userId: UUID
    let imageUrl: String?
    let prediction: String
    let confidence: Double

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case imageUrl = "image_url"
        case prediction
        case confidence
    }
}

/// Persists scan metadata into Supabase tables.
final class SaveResultToSupabase {
    private let config = SupabaseConfiguration()

    func save(userId: UUID, prediction: RetinaPrediction, image: UIImage?) async throws {
        let url = config.baseURL.appending(path: "/rest/v1/scans")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = SaveResultPayload(
            userId: userId,
            imageUrl: image.flatMap { ImageUtils.shared.persistTemporaryPNG($0)?.absoluteString },
            prediction: prediction.label,
            confidence: prediction.confidence
        )
        request.httpBody = try JSONEncoder().encode(payload)
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw SaveError.failed
        }
    }

    enum SaveError: LocalizedError {
        case failed
        var errorDescription: String? { "Unable to save scan. Try again later." }
    }
}
