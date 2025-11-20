import SwiftUI

struct HistoryView: View {
    @StateObject var viewModel: HistoryViewModel

    init(viewModel: HistoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.scans) { record in
                    NavigationLink(value: record) {
                        ScanRecordCard(record: record)
                    }
                }
                .onDelete(perform: delete)
            }
            .listStyle(.plain)
            .navigationDestination(for: SupabaseScanRecord.self) { record in
                ReportDetailView(record: record)
            }
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
                let record = viewModel.scans[index]
                await viewModel.delete(record: record)
            }
        }
    }
}
