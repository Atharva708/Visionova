import CoreML
import SwiftUI
import UIKit

struct RetinaPrediction: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let confidence: Double
    let explanation: String
}

/// Handles CoreML preprocessing and inference for retina scans.
final class MLModelManager {
    private let explanations: [String: String] = [
        "Healthy": "No detectable lesions. Continue regular checkups.",
        "Diabetic Retinopathy": "Signs of microaneurysms detected. Schedule a specialist visit.",
        "Glaucoma": "Optic nerve cupping observed. Monitor intraocular pressure."
    ]

    func preprocess(image: UIImage) -> UIImage {
        image
    }

    func convertToPixelBuffer(image: UIImage) throws -> CVPixelBuffer {
        guard let buffer = image.toPixelBuffer() else { throw ModelError.pixelBuffer }
        return buffer
    }

    func predict(pixelBuffer: CVPixelBuffer) throws -> RetinaPrediction {
        let model = try RetinaClassifier(configuration: MLModelConfiguration())
        let output = try model.prediction(image: pixelBuffer)
        let label = output.target
        let probabilities = output.targetProbability
        let confidence = probabilities[label] ?? probabilities.values.max() ?? 0
        let explanation = explanations[label] ?? "Consult your doctor for a detailed analysis."
        return RetinaPrediction(label: label, confidence: confidence, explanation: explanation)
    }

    func classifyRetina(image: UIImage) async throws -> RetinaPrediction {
        let pixelBuffer = try convertToPixelBuffer(image: image)
        return try predict(pixelBuffer: pixelBuffer)
    }

    enum ModelError: LocalizedError {
        case pixelBuffer

        var errorDescription: String? {
            switch self {
            case .pixelBuffer: return "Unable to create pixel buffer from image."
            }
        }
    }
}
