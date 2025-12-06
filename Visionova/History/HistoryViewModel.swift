import Foundation
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var scans: [SupabaseService.Scan] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let sessionStore: SessionStore

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
        Task { await loadHistory() }
    }

    func loadHistory() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let items = try await SupabaseService.shared.fetchScans()
            // Already ordered by created_at desc in service
            scans = items
        } catch {
            errorMessage = error.localizedDescription
            scans = []
        }
    }

    func delete(record: SupabaseService.Scan) async {
        errorMessage = nil
        do {
            let success = try await SupabaseService.shared.deleteScan(id: record.id)
            guard success else {
                errorMessage = "Failed to delete record"
                return
            }
            if let idx = scans.firstIndex(where: { $0.id == record.id }) {
                scans.remove(at: idx)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
