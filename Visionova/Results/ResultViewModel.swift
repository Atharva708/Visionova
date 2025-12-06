import SwiftUI
import Combine
import Supabase

@MainActor
final class ResultViewModel: ObservableObject {
    @Published var prediction: RetinaPrediction
    @Published var isSaving = false
    @Published var saveMessage: String?

    let image: UIImage?
    private let sessionStore: SessionStore

    init(prediction: RetinaPrediction, image: UIImage?, sessionStore: SessionStore) {
        self.prediction = prediction
        self.image = image
        self.sessionStore = sessionStore
    }

    func save() async {
        guard let session = sessionStore.session else {
            saveMessage = "You must be signed in to save scans."
            return
        }
        isSaving = true
        defer { isSaving = false }

        let uid = session.user.id.uuidString
        let condition = EyeCondition(rawValue: prediction.label.lowercased()) ?? .other
        let explanation = makeExplanation(label: condition, confidence: prediction.confidence, indicators: [])

        do {
            // Upload image if available
            let imageUrl: String
            if let image = image {
                imageUrl = try await SupabaseService.shared.uploadImage(userId: uid, image: image)
            } else {
                imageUrl = ""
            }

            // Build insert payload according to Supabase scans schema
            let insert = SupabaseService.InsertScan(
                user_id: uid,
                image_url: imageUrl,
                prediction: prediction.label,
                confidence: prediction.confidence,
                explanation: explanation
            )

            // Insert the scan record
            _ = try await SupabaseService.shared.insertScan(scan: insert)
            saveMessage = "Saved to Supabase"
        } catch {
            saveMessage = error.localizedDescription
        }
    }
}
