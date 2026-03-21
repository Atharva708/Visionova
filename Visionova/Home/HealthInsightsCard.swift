import SwiftUI

struct HealthInsightsCard: View {
    let insights: [HealthInsight]

    var body: some View {
        VStack(spacing: 16) {
            ForEach(insights) { insight in
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(insight.title)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(colorForTrend(insight.trend))
                                .frame(width: 8, height: 8)
                            Text(insight.trend ?? "")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(colorForTrend(insight.trend))
                        }
                    }
                    
                    Spacer()
                    
                    Text(insight.value)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                }
                
                if insight.id != insights.last?.id {
                    Divider()
                        .background(Color.white.opacity(0.1))
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func colorForTrend(_ trend: String?) -> Color {
        guard let trend = trend?.lowercased() else { return .secondary }
        if trend.contains("optimal") || trend.contains("stable") || trend.contains("normal") || trend.contains("healthy") {
            return .green
        } else if trend.contains("alert") || trend.contains("check") || trend.contains("elevated") {
            return .orange
        } else if trend.contains("needs") {
            return .cyan
        }
        return .white.opacity(0.6)
    }
}
