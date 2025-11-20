import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            TabView(selection: $appState.onboardingManager.currentStep) {
                welcomeSlide
                    .tag(OnboardingManager.Step.welcome)
                PermissionsRequestView()
                    .tag(OnboardingManager.Step.permissions)
                summarySlide
                    .tag(OnboardingManager.Step.summary)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button(action: advance) {
                Text(appState.onboardingManager.currentStep == .summary ? "Finish" : "Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.gradient)
                    .foregroundStyle(.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal)
            .disabled(!canProceed)
        }
        .padding(.vertical, 32)
    }

    private var welcomeSlide: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "eye.circle.fill")
                .font(.system(size: 96))
                .foregroundStyle(Color.blue)
            Text("Welcome to VisioNova Scan")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text("Your AI-powered retina companion. We'll guide you through permissions so we can personalize your insights.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Toggle("I agree to the privacy policy", isOn: $appState.onboardingManager.hasAcceptedTerms)
                .padding()
            Spacer()
        }
        .padding(.horizontal)
    }

    private var summarySlide: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 72))
                .foregroundStyle(.green)
            Text("You're all set!")
                .font(.title.bold())
            Text("You can now start scanning and reviewing your eye health history.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal)
    }

    private var canProceed: Bool {
        switch appState.onboardingManager.currentStep {
        case .welcome:
            return appState.onboardingManager.hasAcceptedTerms
        case .permissions:
            return appState.onboardingManager.cameraGranted &&
            appState.onboardingManager.photoGranted &&
            (appState.onboardingManager.healthGranted || appState.onboardingManager.healthOptional)
        case .summary:
            return true
        }
    }

    private func advance() {
        if appState.onboardingManager.currentStep == .summary {
            appState.onboardingManager.finish()
            appState.selectedTab = .home
        } else {
            appState.onboardingManager.next()
        }
    }
}
