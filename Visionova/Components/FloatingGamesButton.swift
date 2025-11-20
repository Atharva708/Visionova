import SwiftUI
import UIKit

/// Floating action button that deep links into the Visio Home Games app.
struct FloatingGamesButton: View {
    var body: some View {
        Button(action: openGamesApp) {
            HStack(spacing: 8) {
                Image(systemName: "gamecontroller.fill")
                Text("Play")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.blue.gradient)
            .clipShape(Capsule())
            .shadow(radius: 8)
        }
        .accessibilityLabel("Open Visio Games")
    }

    private func openGamesApp() {
        guard let url = URL(string: "visiohome://open") else { return }
        UIApplication.shared.open(url)
    }
}
