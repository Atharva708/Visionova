import SwiftUI
import UniformTypeIdentifiers

struct ScanResultView: View {
    @StateObject var viewModel: ResultViewModel
    @Environment(\.dismiss) var dismiss

    init(viewModel: ResultViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Image
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DIAGNOSIS")
                            .font(.system(size: 12, weight: .black))
                            .tracking(1.5)
                            .foregroundStyle(.cyan)
                        
                        Text(viewModel.prediction.label)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                    }
                    
                    ResultExplanationCard(prediction: viewModel.prediction)
                    
                    recommendations
                    
                    actionButtons
                }
                .padding(.horizontal)
                
                if let message = viewModel.saveMessage {
                    Text(message)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.green)
                        .padding(.bottom, 20)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Analysis")
        .toolbarTitleDisplayMode(.inline)
    }

    private var recommendations: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Recommended Steps", systemImage: "checklist")
                .font(.headline)
            
            Text("This analysis is powered by VisioNova AI. While highly accurate, it is not a doctor's diagnosis. Share this report with your eye specialist and monitor for any sudden vision changes.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(24)
    }

    private var actionButtons: some View {
        VStack(spacing: 14) {
            Button {
                Task {
                    await viewModel.save()
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    dismiss()
                }
            } label: {
                HStack {
                    if viewModel.isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "square.and.arrow.down.fill")
                    }
                    Text(viewModel.isSaving ? "Saving..." : "Save to History")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(20)
            }
            .disabled(viewModel.isSaving)

            if let image = viewModel.image, let data = image.pngData() {
                let shareItem = ScanResultShareItem(data: data)
                ShareLink(item: shareItem, preview: SharePreview("VisioNova Scan Result", image: Image(uiImage: image))) {
                    Label("Export PDF Report", systemImage: "doc.badge.arrow.up.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(RoundedRectangle(cornerRadius: 20).stroke(Color.primary.opacity(0.2), lineWidth: 1.5))
                }
            }
        }
    }
}

struct ScanResultShareItem: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            item.data
        }
    }
}
