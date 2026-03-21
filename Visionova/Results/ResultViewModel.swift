import SwiftUI
import Combine

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
        isSaving = true
        defer { isSaving = false }

        _ = LocalHistoryStore.shared.append(
            image: image,
            prediction: prediction.label,
            confidence: prediction.confidence,
            explanation: prediction.explanation
        )
        saveMessage = "Saved to device"
    }
}
