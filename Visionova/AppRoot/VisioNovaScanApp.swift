import SwiftUI

/// Entry point for VisioNova Scan.
@main
struct VisioNovaScanApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(appState)
        }
    }
}
