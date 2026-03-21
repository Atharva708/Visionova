import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject var viewModel: HomeViewModel
    @State private var animateItems = false

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Nova Theme Background
                Color(red: 0.05, green: 0.07, blue: 0.18).ignoresSafeArea()
                
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 400, height: 400)
                    .blur(radius: 80)
                    .offset(x: -150, y: -200)
                
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 350, height: 350)
                    .blur(radius: 70)
                    .offset(x: 180, y: 300)

                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        welcomeHeader
                            .offset(y: animateItems ? 0 : 20)
                            .opacity(animateItems ? 1 : 0)
                        
                        lastScanSection
                            .offset(y: animateItems ? 0 : 20)
                            .opacity(animateItems ? 1 : 0)
                        
                        insightsSection
                            .offset(y: animateItems ? 0 : 20)
                            .opacity(animateItems ? 1 : 0)
                        
                        newsSection
                            .offset(y: animateItems ? 0 : 20)
                            .opacity(animateItems ? 1 : 0)
                        
                        scanCTA
                            .padding(.bottom, 20)
                            .offset(y: animateItems ? 0 : 20)
                            .opacity(animateItems ? 1 : 0)
                    }
                    .padding()
                }
                .refreshable { await viewModel.refresh() }
            }
            .navigationTitle("Visionova")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { Task { await viewModel.refresh() } }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateItems = true
                }
            }
        }
    }

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome, \(appState.sessionStore.session?.email.split(separator: "@").first?.description.capitalized ?? "Friend")")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Your eye health at a glance")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.top, 10)
    }

    private var newsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Latest News")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            VStack(spacing: 12) {
                ForEach(viewModel.news) { article in
                    NewsCard(article: article)
                }
            }
        }
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health Insights")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            HealthInsightsCard(insights: viewModel.healthInsights)
        }
    }

    private var lastScanSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Analysis")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            if let summary = viewModel.lastScan {
                LastScanCard(summary: summary)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "eye.trianglebadge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.3))
                    Text("No scans found yet")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(.ultraThinMaterial)
                .cornerRadius(32)
            }
        }
    }

    private var scanCTA: some View {
        Button {
            appState.selectedTab = .scan
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Image(systemName: "camera.macro")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start New Scan")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Check your retina health now")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(20)
            .background(
                LinearGradient(colors: [Color.cyan.opacity(0.8), Color.blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(28)
            .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 10)
        }
    }
}
