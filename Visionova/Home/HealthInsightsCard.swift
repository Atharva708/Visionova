import SwiftUI

struct HealthInsightsCard: View {
    let insights: [HealthInsight]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(insights) { insight in
                HStack {
                    VStack(alignment: .leading) {
                        Text(insight.title)
                            .font(.headline)
                        Text(insight.trend ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(insight.value)
                        .font(.title3.bold())
                }
                if insight.id != insights.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
}
