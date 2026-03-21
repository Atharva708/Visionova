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
        if let latest = LocalHistoryStore.shared.load().first {
            lastScan = ScanSummary(
                diagnosis: latest.prediction,
                confidence: latest.confidence,
                createdAt: latest.createdAt,
                recommendations: "Follow up with an eye specialist if symptoms persist."
            )
        }
    }

    private func fetchHealthInsights() async {
        var insights: [HealthInsight] = []
        
        // 1. Sleep
        if let sleepHours = try? await healthKitManager.fetchSleep() {
            insights.append(HealthInsight(title: "Sleep", value: String(format: "%.1f h", sleepHours), trend: sleepHours >= 7 ? "Optimal" : "Needs rest"))
        }
        
        // 2. Heart Rate
        if let heartRate = try? await healthKitManager.fetchHeartRate() {
            insights.append(HealthInsight(title: "Heart Rate", value: String(format: "%.0f bpm", heartRate), trend: heartRate < 80 ? "Stable" : "Elevated"))
        }

        // 3. Blood Glucose (New)
        if let glucose = try? await healthKitManager.fetchBloodGlucose(), glucose > 0 {
            let trend = glucose < 140 ? "Normal" : "High (Alert)"
            insights.append(HealthInsight(title: "Blood Glucose", value: String(format: "%.0f mg/dL", glucose), trend: trend))
        }

        // 4. Blood Pressure (New)
        if let bp = try? await healthKitManager.fetchBloodPressure(), bp.systolic > 0 {
            let value = String(format: "%.0f/%.0f", bp.systolic, bp.diastolic)
            let trend = bp.systolic < 130 ? "Healthy" : "Check Pressure"
            insights.append(HealthInsight(title: "Blood Pressure", value: value, trend: trend))
        }

        if insights.isEmpty {
            insights.append(HealthInsight(title: "Health Data", value: "Pending", trend: "Enable HealthKit"))
        }
        healthInsights = insights
    }
}

