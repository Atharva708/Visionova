import SwiftUI
import UIKit

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()

    private let conditionInfo: [String: (what: String, causes: String)] = [
        "normal": (
            what: "No abnormal findings detected in the retina.",
            causes: "Healthy retina without visible lesions, hemorrhages, or structural changes."
        ),
        "diabetic retinopathy": (
            what: "Damage to retinal blood vessels associated with diabetes.",
            causes: "High blood sugar over time causing microaneurysms, hemorrhages, and neovascularization."
        ),
        "glaucoma": (
            what: "Progressive optic nerve damage that can lead to vision loss.",
            causes: "Often related to elevated intraocular pressure; family history and age increase risk."
        ),
        "age-related macular degeneration": (
            what: "Degeneration of the macula affecting central vision.",
            causes: "Aging, smoking, and genetic factors; drusen deposits and macular changes are typical."
        ),
        "amd": (
            what: "Degeneration of the macula affecting central vision.",
            causes: "Aging, smoking, and genetic factors; drusen deposits and macular changes are typical."
        ),
        "cataract": (
            what: "Clouding of the eye’s natural lens causing blurry vision.",
            causes: "Aging, UV exposure, diabetes, and certain medications can accelerate lens clouding."
        )
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.scans, id: \.id) { scan in
                    NavigationLink {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                if let path = scan.imagePath,
                                   let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(path),
                                   let uiImage = UIImage(contentsOfFile: url.path) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(12)
                                }

                                Group {
                                    Text(scan.prediction)
                                        .font(.title.bold())
                                    Text("Confidence: \(Int(scan.confidence * 100))%")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Text(scan.createdAt, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Divider()

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("AI Explanation")
                                        .font(.headline)
                                    Text(scan.explanation)
                                        .font(.body)
                                }

                                let key = scan.prediction.lowercased()
                                if let info = conditionInfo[key] {
                                    Divider()
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("About this condition")
                                            .font(.headline)
                                        Text("What it is: \(info.what)")
                                        Text("Probable causes: \(info.causes)")
                                    }
                                }
                            }
                            .padding()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            if let path = scan.imagePath,
                               let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(path),
                               let uiImage = UIImage(contentsOfFile: url.path) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 56, height: 56)
                                    .clipped()
                                    .cornerRadius(8)
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.secondarySystemBackground))
                                    .frame(width: 56, height: 56)
                                    .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                            }
                            VStack(alignment: .leading) {
                                Text(scan.prediction).font(.headline)
                                Text("Confidence: \(Int(scan.confidence * 100))%")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(scan.createdAt, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
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
}
