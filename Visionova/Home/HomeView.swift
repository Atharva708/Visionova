import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    welcomeHeader
                    newsSection
                    insightsSection
                    lastScanSection
                    scanCTA
                }
                .padding()
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { Task { await viewModel.refresh() } }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome, \(appState.sessionStore.session?.user.email ?? "Friend")")
                .font(.title.bold())
            Text("Here is your eye health overview")
                .foregroundStyle(.secondary)
        }
    }

    private var newsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Latest Eye Health News")
                .font(.title3.bold())
            ForEach(viewModel.news) { article in
                NewsCard(article: article)
            }
        }
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Health Insights")
                .font(.title3.bold())
            HealthInsightsCard(insights: viewModel.healthInsights)
        }
    }

    private var lastScanSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last Scan Summary")
                .font(.title3.bold())
            if let summary = viewModel.lastScan {
                LastScanCard(summary: summary)
            } else {
                Text("No scans yet. Start by capturing your first retina image.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var scanCTA: some View {
        Button {
            appState.selectedTab = .scan
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text("Ready for your next scan?")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Capture or upload a retina image now.")
                        .foregroundStyle(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white)
            }
            .padding()
            .background(Color.green.gradient)
            .cornerRadius(18)
        }
    }
}
