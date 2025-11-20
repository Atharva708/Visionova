import SwiftUI
import Combine

@MainActor
final class ResultViewModel: ObservableObject {
    @Published var prediction: RetinaPrediction
    @Published var isSaving = false
    @Published var saveMessage: String?

    let image: UIImage?
    private let sessionStore: SessionStore
    private let saver = SaveResultToSupabase()

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
        do {
            try await saver.save(userId: session.user.id, accessToken: session.accessToken, prediction: prediction, image: image)
            saveMessage = "Saved to Supabase"
        } catch {
            saveMessage = error.localizedDescription
        }
    }
}
