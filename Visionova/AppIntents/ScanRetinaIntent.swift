import AppIntents
import SwiftUI

struct ScanRetinaIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Retina Scan"
    static var description = IntentDescription("Opens Visionova and starts a new retina scan.")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: NSNotification.Name("VisionovaDeepLinkToScan"), object: nil)
        return .result()
    }
}

struct VisionovaShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ScanRetinaIntent(),
            phrases: [
                "Start a Retina Scan in \(.applicationName)",
                "Scan my eye in \(.applicationName)"
            ],
            shortTitle: "Scan Retina",
            systemImageName: "eye.fill"
        )
    }
}
