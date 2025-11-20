import SwiftUI

struct ResultExplanationCard: View {
    let prediction: RetinaPrediction

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Explanation")
                .font(.headline)
            Text(prediction.explanation)
                .foregroundStyle(.secondary)
            ProgressView(value: prediction.confidence)
            Text("Confidence: \(Int(prediction.confidence * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
}
