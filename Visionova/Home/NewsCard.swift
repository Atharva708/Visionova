import SwiftUI

struct NewsCard: View {
    let article: EyeNewsArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.headline)
            Text(article.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let url = article.url {
                Link("Read more", destination: url)
                    .font(.footnote.bold())
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
}
