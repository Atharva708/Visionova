import Foundation
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var scans: [LocalScanRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        Task { await loadHistory() }
    }

    func loadHistory() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        scans = LocalHistoryStore.shared.load()
    }

    func delete(record: LocalScanRecord) async {
        errorMessage = nil
        LocalHistoryStore.shared.delete(id: record.id)
        if let idx = scans.firstIndex(where: { $0.id == record.id }) {
            scans.remove(at: idx)
        }
    }
}
