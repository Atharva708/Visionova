import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.07, blue: 0.18),
                    Color(red: 0.02, green: 0.18, blue: 0.36)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()
                logoSection
                
                Spacer()
                
                Button(action: login) {
                    HStack {
                        if appState.sessionStore.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "faceid")
                                .font(.title2)
                        }
                        Text(appState.sessionStore.isLoading ? "Authenticating..." : "Unlock Visionova")
                            .fontWeight(.bold)
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundStyle(.white)
                    .cornerRadius(24)
                    .shadow(color: .blue.opacity(0.4), radius: 20, y: 12)
                }
                .disabled(appState.sessionStore.isLoading)
                .padding(.horizontal, 32)
                
                if let error = appState.sessionStore.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .onAppear {
            // Auto prompt FaceID when view loads
            login()
        }
    }

    private var logoSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(.thinMaterial)
                    .frame(width: 140, height: 140)
                    .shadow(color: .white.opacity(0.2), radius: 30, y: 15)

                if let logo = UIImage(named: "VisioNovaLogo") {
                    Image(uiImage: logo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                } else {
                    Image(systemName: "eye.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)
                }
            }
            Text("VisioNova Scan")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Privacy-first retinal health insights.")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
        }
    }

    private func login() {
        Task {
            await appState.sessionStore.signIn()
            if appState.sessionStore.isAuthenticated {
                await MainActor.run {
                    appState.selectedTab = .home
                }
            }
        }
    }
}
