import SwiftUI

struct LastScanCard: View {
    let summary: ScanSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(summary.diagnosis)
                    .font(.title2.bold())
                Spacer()
                Text(summary.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: summary.confidence)
            Text("Confidence: \(Int(summary.confidence * 100))%")
                .font(.subheadline)
            Text(summary.recommendations)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.secondarySystemBackground)))
    }
}
