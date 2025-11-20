import Foundation
import Combine

struct EyeNewsArticle: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let url: URL?
}

struct ScanSummary {
    let diagnosis: String
    let confidence: Double
    let createdAt: Date
    let recommendations: String
}

/// Populates the Home tab data such as news, last scan, and insights.
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var news: [EyeNewsArticle] = []
    @Published var lastScan: ScanSummary?
    @Published var healthInsights: [HealthInsight] = []

    private let healthKitManager: HealthKitManager
    private let sessionStore: SessionStore

    init(healthKitManager: HealthKitManager, sessionStore: SessionStore) {
        self.healthKitManager = healthKitManager
        self.sessionStore = sessionStore
        Task { await refresh() }
    }

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        await fetchNews()
        await fetchLastScan()
        await fetchHealthInsights()
    }

    private func fetchNews() async {
        // Placeholder static articles. Replace with real API integration.
        news = [
            EyeNewsArticle(title: "AI detects diabetic retinopathy earlier", summary: "Recent studies show AI models spot early signs from fundus photos with 95% accuracy.", url: URL(string: "https://newsroom.visio/ai-retina")),
            EyeNewsArticle(title: "Blue light hygiene tips", summary: "Follow the 20-20-20 rule to keep your eyes relaxed during screen time.", url: URL(string: "https://newsroom.visio/blue-light"))
        ]
    }

    private func fetchLastScan() async {
        guard let session = sessionStore.session else { return }
        do {
            let request = try SupabaseTable.scans(userId: session.user.id).urlRequest(accessToken: session.accessToken, limit: 1)
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try decoder.decode([SupabaseScanRecord].self, from: data)
            if let latest = response.sorted(by: { $0.createdAt > $1.createdAt }).first {
                lastScan = ScanSummary(
                    diagnosis: latest.prediction,
                    confidence: latest.confidence,
                    createdAt: latest.createdAt,
                    recommendations: "Follow up with an eye specialist within 2 weeks."
                )
            }
        } catch {
            // Fallback to placeholder if Supabase read fails.
            lastScan = ScanSummary(diagnosis: "Healthy", confidence: 0.92, createdAt: Date(), recommendations: "Keep monitoring monthly.")
        }
    }

    private func fetchHealthInsights() async {
        var insights: [HealthInsight] = []
        if let sleepHours = try? await healthKitManager.fetchSleep() {
            insights.append(HealthInsight(title: "Sleep", value: String(format: "%.1f h", sleepHours), trend: sleepHours >= 7 ? "On track" : "Needs rest"))
        }
        if let heartRate = try? await healthKitManager.fetchHeartRate() {
            insights.append(HealthInsight(title: "Heart Rate", value: String(format: "%.0f bpm", heartRate), trend: heartRate < 80 ? "Calm" : "Elevated"))
        }
        if insights.isEmpty {
            insights.append(HealthInsight(title: "HealthKit", value: "Awaiting data", trend: "Grant permissions"))
        }
        healthInsights = insights
    }
}

