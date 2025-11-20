import SwiftUI
import Combine

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
        } catch {
            errorMessage = error.localizedDescription
        }
        isProcessing = false
    }
}
