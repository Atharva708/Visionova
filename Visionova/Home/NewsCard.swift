import SwiftUI

struct NewsCard: View {
    let article: EyeNewsArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(article.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
            
            Text(article.summary)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(3)
            
            if let url = article.url {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Text("Learn more")
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.cyan)
                }
                .padding(.top, 4)
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
}
