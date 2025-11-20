import SwiftUI

/// Routes between authentication, onboarding, and the main tab experience.
struct AppRouter: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if !appState.sessionStore.isAuthenticated {
                    AuthenticationStack()
                } else if !appState.onboardingManager.isOnboardingComplete {
                    OnboardingView()
                } else {
                    MainTabContainer()
                }
            }
            .animation(.easeInOut, value: appState.sessionStore.isAuthenticated)
            .animation(.easeInOut, value: appState.onboardingManager.isOnboardingComplete)

            if appState.shouldShowFloatingButton {
                FloatingGamesButton()
                    .padding(.trailing, 16)
                    .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $appState.isProfilePresented) {
            ProfileView(viewModel: ProfileViewModel(sessionStore: appState.sessionStore, healthKitManager: appState.healthKitManager))
        }
    }
}

// MARK: - Authentication Stack

private struct AuthenticationStack: View {
    @EnvironmentObject private var appState: AppState
    @State private var isShowingSignup = false

    var body: some View {
        NavigationStack {
            LoginView(isPresentingSignup: $isShowingSignup)
                .toolbar(.hidden, for: .navigationBar)
                .sheet(isPresented: $isShowingSignup) {
                    SignupView(isPresented: $isShowingSignup)
                }
        }
    }
}

// MARK: - Main Tab Container

private struct MainTabContainer: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView(viewModel: HomeViewModel(healthKitManager: appState.healthKitManager, sessionStore: appState.sessionStore))
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppState.MainTab.home)

            ScanView(viewModel: CameraViewModel())
                .tabItem {
                    Label("Scan", systemImage: "camera.macro")
                }
                .tag(AppState.MainTab.scan)

            HistoryView(viewModel: HistoryViewModel(sessionStore: appState.sessionStore))
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(AppState.MainTab.history)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                appState.isProfilePresented = true
            } label: {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 24))
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .padding()
            }
        }
    }
}
