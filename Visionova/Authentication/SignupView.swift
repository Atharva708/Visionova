import SwiftUI

struct SignupView: View {
    @EnvironmentObject private var appState: AppState
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    private let userService = SupabaseUserService()

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                }

                Section {
                    Button(action: signup) {
                        if appState.sessionStore.isLoading {
                            ProgressView()
                        } else {
                            Text("Create Account")
                        }
                    }
                    .disabled(!canSubmit)
                }

                if let error = appState.sessionStore.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Sign Up")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { isPresented = false }
                }
            }
        }
    }

    private var canSubmit: Bool {
        !email.isEmpty && password == confirmPassword && password.count >= 8
    }

    private func signup() {
        Task {
            await appState.sessionStore.signUp(email: email, password: password)
            guard let session = appState.sessionStore.session else { return }
            do {
                try await userService.ensureUserExists(session: session)
            } catch {
                await MainActor.run {
                    appState.sessionStore.errorMessage = error.localizedDescription
                }
                return
            }
            await MainActor.run {
                isPresented = false
                appState.onboardingManager.finish()
                appState.selectedTab = .home
            }
        }
    }
}
