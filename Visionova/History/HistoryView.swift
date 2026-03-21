import SwiftUI
import UIKit

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()

    private let conditionInfo: [String: (what: String, causes: String)] = [
        "healthy": (
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
        "cataract": (
            what: "Clouding of the eye’s natural lens causing blurry vision.",
            causes: "Aging, UV exposure, diabetes, and certain medications can accelerate lens clouding."
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.07, blue: 0.18).ignoresSafeArea()
                
                List {
                    ForEach(viewModel.scans, id: \.id) { scan in
                        NavigationLink {
                            detailView(for: scan)
                        } label: {
                            localScanRow(for: scan)
                        }
                        .listRowBackground(Color.white.opacity(0.05))
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .navigationTitle("History")
                .toolbarBackground(.hidden, for: .navigationBar)
                .refreshable { await viewModel.loadHistory() }
                .overlay {
                    if viewModel.scans.isEmpty && !viewModel.isLoading {
                        ContentUnavailableView {
                            Label("No scans yet", systemImage: "clock.badge.exclamationmark")
                        } description: {
                            Text("Your scan history will appear here once you start analyzing.")
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
            }
        }
    }

    private func localScanRow(for scan: LocalScanRecord) -> some View {
        HStack(spacing: 16) {
            if let path = scan.imagePath,
               let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(path),
               let uiImage = UIImage(contentsOfFile: url.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .frame(width: 64, height: 64)
                    .overlay(Image(systemName: "photo").foregroundStyle(.white.opacity(0.3)))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(scan.prediction)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(scan.createdAt, style: .date)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Spacer()
            
            Text("\(Int(scan.confidence * 100))%")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(.cyan)
        }
        .padding(.vertical, 8)
    }

    private func detailView(for scan: LocalScanRecord) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let path = scan.imagePath,
                   let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(path),
                   let uiImage = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                }

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(scan.prediction)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        
                        Text("Analyzed on \(scan.createdAt.formatted(date: .complete, time: .shortened))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI INSIGHTS")
                            .font(.system(size: 12, weight: .black))
                            .tracking(1.5)
                            .foregroundStyle(.cyan)
                        
                        Text(scan.explanation)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(24)

                    let key = scan.prediction.lowercased()
                    if let info = conditionInfo[key] {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("MEDICAL CONTEXT")
                                .font(.system(size: 12, weight: .black))
                                .tracking(1.5)
                                .foregroundStyle(.cyan)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("**What it is:** \(info.what)")
                                Text("**Common causes:** \(info.causes)")
                            }
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                        }
                        .padding(20)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(24)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Report Details")
        .toolbarTitleDisplayMode(.inline)
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
