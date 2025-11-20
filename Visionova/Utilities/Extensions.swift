import SwiftUI

extension View {
    func cardStyle() -> some View {
        padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
}
