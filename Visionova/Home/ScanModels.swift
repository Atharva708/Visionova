import Foundation

/// Represents an eye scan record matching the `public.scans` table.
public struct EyeScan: Codable, Sendable, Identifiable {
    /// Unique identifier of the scan.
    public let id: UUID
    /// Date and time when the scan was performed.
    public let timestamp: Date
    /// Confidence level of the scan result (0.0 to 1.0).
    public let confidence: Double
    /// Label identifying the detected eye condition.
    public let label: EyeCondition
    /// List of indicators detected in the scan.
    public let indicators: [String]

    /// Creates a new EyeScan instance.
    /// - Parameters:
    ///   - id: Unique identifier of the scan.
    ///   - timestamp: Date and time when the scan was performed.
    ///   - confidence: Confidence level of the scan result (0.0 to 1.0).
    ///   - label: Label identifying the detected eye condition.
    ///   - indicators: List of indicators detected in the scan.
    public init(id: UUID, timestamp: Date, confidence: Double, label: EyeCondition, indicators: [String]) {
        self.id = id
        self.timestamp = timestamp
        self.confidence = confidence
        self.label = label
        self.indicators = indicators
    }
}

/// Possible eye conditions detected by an eye scan.
public enum EyeCondition: String, Codable, Sendable, CaseIterable {
    /// No abnormalities detected.
    case normal = "normal"
    /// Diabetic retinopathy condition detected.
    case diabeticRetinopathy = "diabetic_retinopathy"
    /// Glaucoma condition detected.
    case glaucoma = "glaucoma"
    /// Age-related macular degeneration detected.
    case ageRelatedMacularDegeneration = "age_related_macular_degeneration"
    /// Cataract detected.
    case cataract = "cataract"
    /// Other unspecified conditions.
    case other = "other"
}

/// Provides explanations for each eye condition.
public let ConditionExplanation: [EyeCondition: String] = [
    .normal: "No signs of eye disease were detected in the scan.",
    .diabeticRetinopathy: "Diabetic retinopathy is damage to the retina caused by complications of diabetes, which can lead to blindness.",
    .glaucoma: "Glaucoma is a group of eye conditions that damage the optic nerve, often due to high eye pressure.",
    .ageRelatedMacularDegeneration: "Age-related macular degeneration (AMD) is a common eye condition that results in the deterioration of the macula, leading to vision loss.",
    .cataract: "A cataract causes clouding of the eye's natural lens, leading to blurred vision.",
    .other: "An eye condition was detected that does not fall into the common categories."
]

/// Creates a detailed explanation of an eye scan result.
///
/// - Parameters:
///   - label: The detected eye condition label.
///   - confidence: The confidence value associated with the detection (0.0 to 1.0).
///   - indicators: The list of detected indicators contributing to the detection.
///
/// - Returns: A detailed explanation string combining the condition explanation, confidence, and indicators.
public func makeExplanation(label: EyeCondition, confidence: Double, indicators: [String]) -> String {
    let explanation = ConditionExplanation[label] ?? "No further information available."
    let confidencePct = String(format: "%.1f", confidence * 100)
    let indicatorsList = indicators.isEmpty ? "None" : indicators.joined(separator: ", ")
    return """
    Condition: \(label.rawValue.capitalized)
    Confidence: \(confidencePct)%
    Explanation: \(explanation)
    Indicators: \(indicatorsList)
    """
}
