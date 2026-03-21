import CoreML
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

struct RetinaPrediction: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let confidence: Double
    let explanation: String
}

/// Handles CoreImage preprocessing and Vision-based inference for retina scans.
final class MLModelManager {
    private let explanations: [String: String] = [
        "Healthy": "No detectable lesions. Continue regular checkups.",
        "Diabetic Retinopathy": "Signs of microaneurysms detected. Schedule a specialist visit.",
        "Glaucoma": "Optic nerve cupping observed. Monitor intraocular pressure."
    ]

    private let context = CIContext()

    /// Uses CoreImage to auto-enhance the retinal image for better ML classification.
    func autoEnhance(image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        
        // 1. Color Controls to boost contrast and subtle brightness
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.contrast = 1.15
        filter.brightness = 0.05
        filter.saturation = 1.1

        // 2. Unsharp Mask to improve the visibility of blood vessels and microaneurysms
        let unsharp = CIFilter.unsharpMask()
        unsharp.inputImage = filter.outputImage
        unsharp.radius = 2.5
        unsharp.intensity = 0.6

        guard let output = unsharp.outputImage,
              let cgImage = context.createCGImage(output, from: output.extent) else {
            return image
        }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    /// Pre-process and run ML Inference on the enhanced image natively utilizing the Vision framework.
    func classifyRetina(image: UIImage) async throws -> RetinaPrediction {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let config = MLModelConfiguration()
                let model = try RetinaClassifier(configuration: config)
                guard let visionModel = try? VNCoreMLModel(for: model.model) else {
                    continuation.resume(throwing: ModelError.visionModel)
                    return
                }

                let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
                    guard let self = self else { return }
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    if let results = request.results as? [VNClassificationObservation], let topResult = results.first {
                        let label = topResult.identifier
                        let confidence = Double(topResult.confidence)
                        let explanation = self.explanations[label] ?? "Consult your doctor for a detailed analysis."
                        
                        let prediction = RetinaPrediction(label: label, confidence: confidence, explanation: explanation)
                        continuation.resume(returning: prediction)
                    } else {
                        continuation.resume(throwing: ModelError.noResults)
                    }
                }
                
                // Crop to center mimicking typical camera/fundus perspectives
                request.imageCropAndScaleOption = .centerCrop
                
                // Enhance before ML processing
                let enhancedImage = self.autoEnhance(image: image)
                guard let cgImage = enhancedImage.cgImage else {
                    continuation.resume(throwing: ModelError.pixelBuffer)
                    return
                }

                // Vision natively handles orientation automatically here
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        try handler.perform([request])
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    enum ModelError: LocalizedError {
        case pixelBuffer
        case visionModel
        case noResults
        
        var errorDescription: String? {
            switch self {
            case .pixelBuffer: return "Unable to process the image for analysis."
            case .visionModel: return "Failed to load Apple Vision ML Model."
            case .noResults: return "No classification results found."
            }
        }
    }
}
