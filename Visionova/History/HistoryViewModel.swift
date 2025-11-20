import Foundation
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var scans: [SupabaseScanRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let sessionStore: SessionStore
    private let config = SupabaseConfiguration()

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
        Task { await loadHistory() }
    }

    func loadHistory() async {
        guard let session = sessionStore.session else { return }
        let userId = session.user.id
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let request = try SupabaseTable.scans(userId: userId).urlRequest(accessToken: session.accessToken)
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            scans = try decoder.decode([SupabaseScanRecord].self, from: data).sorted(by: { $0.createdAt > $1.createdAt })
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(record: SupabaseScanRecord) async {
        guard let session = sessionStore.session else { return }
        let userId = session.user.id
        do {
            var components = URLComponents(url: config.baseURL.appending(path: "/rest/v1/scans"), resolvingAgainstBaseURL: false)
            components?.queryItems = [
                URLQueryItem(name: "id", value: "eq.\(record.id.uuidString)"),
                URLQueryItem(name: "user_id", value: "eq.\(userId.uuidString)")
            ]
            guard let url = components?.url else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
            _ = try await URLSession.shared.data(for: request)
            scans.removeAll { $0.id == record.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
