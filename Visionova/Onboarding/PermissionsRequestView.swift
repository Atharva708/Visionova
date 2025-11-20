import SwiftUI
import AVFoundation
import Photos

struct PermissionsRequestView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Text("Enable essential permissions")
                .font(.title.bold())
                .multilineTextAlignment(.center)
            permissionRow(icon: "camera.fill", title: "Camera", granted: appState.onboardingManager.cameraGranted) {
                await requestCamera()
            }
            permissionRow(icon: "photo.on.rectangle", title: "Photos", granted: appState.onboardingManager.photoGranted) {
                await requestPhotos()
            }
            permissionRow(icon: "heart.fill", title: "HealthKit", granted: appState.onboardingManager.healthGranted) {
                await requestHealthKit()
            }
            Spacer()
        }
        .padding()
    }

    private func permissionRow(icon: String, title: String, granted: Bool, action: @escaping () async -> Void) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(granted ? .green : .orange)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(granted ? "Granted" : "Tap to enable")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(granted ? "Done" : "Allow") {
                Task { await action() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(granted)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private func requestCamera() async {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        await MainActor.run { appState.onboardingManager.cameraGranted = granted }
    }

    private func requestPhotos() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        await MainActor.run { appState.onboardingManager.photoGranted = status == .authorized || status == .limited }
    }

    private func requestHealthKit() async {
        do {
            let granted = try await appState.healthKitManager.requestPermissions()
            await MainActor.run { appState.onboardingManager.healthGranted = granted }
        } catch {
            await MainActor.run { appState.onboardingManager.healthGranted = false }
        }
    }
}
