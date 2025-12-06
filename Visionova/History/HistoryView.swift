import SwiftUI

struct HistoryView: View {
    @StateObject var viewModel: HistoryViewModel

    init(viewModel: HistoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.scans, id: \.id) { scan in
                    let record = mapToSupabaseScanRecord(scan)
                    NavigationLink(destination: ReportDetailView(record: record)) {
                        ScanRecordCard(record: record)
                    }
                }
                .onDelete(perform: delete)
            }
            .listStyle(.plain)
            .navigationTitle("History")
            .refreshable { await viewModel.loadHistory() }
            .overlay {
                if viewModel.scans.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView("No scans", systemImage: "clock", description: Text("Run your first scan to build history."))
                }
            }
        }
    }

    private func delete(offsets: IndexSet) {
        Task {
            for index in offsets {
                let scan = viewModel.scans[index]
                await viewModel.delete(record: scan)
            }
        }
    }

    private func mapToSupabaseScanRecord(_ scan: SupabaseService.Scan) -> SupabaseScanRecord {
        let createdAt: Date = ISO8601DateFormatter().date(from: scan.created_at) ?? Date()
        let userUUID = UUID(uuidString: scan.user_id) ?? UUID()
        return SupabaseScanRecord(
            id: scan.id,
            userId: userUUID,
            imageUrl: scan.image_url.isEmpty ? nil : scan.image_url,
            prediction: scan.prediction,
            confidence: scan.confidence,
            createdAt: createdAt
        )
    }
}
