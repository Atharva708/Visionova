import SwiftUI

struct LastScanCard: View {
    let summary: ScanSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("LATEST SCAN")
                        .font(.system(size: 10, weight: .black))
                        .tracking(1.2)
                        .foregroundStyle(.cyan)
                    
                    Text(summary.diagnosis)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Text(summary.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("AI Confidence")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                    Text("\(Int(summary.confidence * 100))%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(
                                LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: geo.size.width * CGFloat(summary.confidence), height: 8)
                            .shadow(color: .cyan.opacity(0.5), radius: 6, x: 0, y: 0)
                    }
                }
                .frame(height: 8)
            }
            
            Text(summary.recommendations)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
                .padding(.top, 4)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.2), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
    }
}
