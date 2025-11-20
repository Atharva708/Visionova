import SwiftUI

struct ReportDetailView: View {
    let record: SupabaseScanRecord

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(record.prediction)
                    .font(.largeTitle.bold())
                Text("Confidence: \(Int(record.confidence * 100))%")
                    .font(.headline)
                Text("Captured on \(record.createdAt.formatted(date: .complete, time: .shortened))")
                    .foregroundStyle(.secondary)
                Divider()
                Text("Insights")
                    .font(.headline)
                Text("Your scan suggests \(record.prediction.lowercased()). Please consult an eye care professional for a definitive diagnosis.")
                if let urlString = record.imageUrl, let url = URL(string: urlString) {
                    Link("View Image", destination: url)
                        .font(.headline)
                }
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Report")
        .toolbarTitleDisplayMode(.inline)
    }
}
