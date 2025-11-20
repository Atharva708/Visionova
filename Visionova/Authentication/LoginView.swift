import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?
    @Binding var isPresentingSignup: Bool

    private enum Field {
        case email
        case password
    }

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

            ScrollView {
                VStack(spacing: 32) {
                    logoSection
                    credentialCard
                    footerActions
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 36)
            }
        }
    }

    private var logoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.thinMaterial)
                    .frame(width: 110, height: 110)
                    .shadow(color: .white.opacity(0.25), radius: 25, y: 10)

                if let logo = UIImage(named: "VisioNovaLogo") {
                    Image(uiImage: logo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                } else {
                    Image(systemName: "eye.circle.fill")
                        .font(.system(size: 68))
                        .foregroundStyle(.white)
                }
            }
            Text("VisioNova Scan")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Text("Precision retinal health insights powered by AI.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
        }
    }

    private var credentialCard: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Email")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("you@visionova.app", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .email)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Password")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                SecureField("••••••••", text: $password)
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
            }

            Button(action: login) {
                HStack {
                    if appState.sessionStore.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(appState.sessionStore.isLoading ? "Signing in..." : "Continue")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)
                )
                .foregroundStyle(.white)
                .cornerRadius(20)
                .shadow(color: .blue.opacity(0.3), radius: 18, y: 12)
            }
            .disabled(appState.sessionStore.isLoading || email.isEmpty || password.isEmpty)

            if let error = appState.sessionStore.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.2), radius: 40, y: 25)
        )
    }

    private var footerActions: some View {
        VStack(spacing: 10) {
            Button("Forgot password?") {
                focusedField = nil
            }
            .font(.callout)
            .foregroundStyle(.white.opacity(0.9))

            HStack(spacing: 4) {
                Text("New to VisioNova?")
                    .foregroundStyle(.white.opacity(0.8))
                Button("Create account") {
                    isPresentingSignup = true
                }
                .fontWeight(.semibold)
            }
            .font(.callout)
        }
        .frame(maxWidth: .infinity)
    }

    private func login() {
        Task {
            await appState.sessionStore.signIn(email: email, password: password)
            if appState.sessionStore.isAuthenticated {
                await MainActor.run {
                    appState.selectedTab = .home
                }
            }
        }
    }
}
