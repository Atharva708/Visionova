import SwiftUI
import Combine
import UIKit

/// Bridges the camera capture pipeline with CoreML inference.
@MainActor
final class CameraViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var prediction: RetinaPrediction?
    @Published var isProcessing = false
    @Published var errorMessage: String?

    let captureService = AVCaptureService()
    private let modelManager = MLModelManager()

    func startSession() {
        captureService.startSession()
    }

    func stopSession() {
        captureService.stopSession()
    }

    func capturePhoto() {
        captureService.capturePhoto { [weak self] image in
            guard let self, let image else {
                self?.errorMessage = "Failed to capture image"
                return
            }
            Task { await self.handleImage(image) }
        }
    }

    func handleImage(_ image: UIImage) async {
        capturedImage = image
        await runPrediction(on: image)
    }

    private func runPrediction(on image: UIImage) async {
        isProcessing = true
        errorMessage = nil
        do {
            prediction = try await modelManager.classifyRetina(image: image)
            if let pred = prediction {
                let normalized = pred.label.lowercased()
                let condition = EyeCondition(rawValue: normalized)
                    ?? (normalized == "healthy" ? .normal :
                        normalized == "amd" ? .ageRelatedMacularDegeneration :
                        normalized == "diabetic retinopathy" ? .diabeticRetinopathy :
                        normalized == "age-related macular degeneration" ? .ageRelatedMacularDegeneration :
                        normalized == "cataract" ? .cataract :
                        normalized == "glaucoma" ? .glaucoma : .other)
                let explanation = makeExplanation(label: condition, confidence: pred.confidence, indicators: [])
                _ = LocalHistoryStore.shared.append(image: image, prediction: pred.label, confidence: pred.confidence, explanation: explanation)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isProcessing = false
    }
}
