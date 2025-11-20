import SwiftUI
import UniformTypeIdentifiers

struct ScanResultView: View {
    @StateObject var viewModel: ResultViewModel

    init(viewModel: ResultViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(20)
                        .shadow(radius: 8)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("Diagnosis")
                        .font(.headline)
                    Text(viewModel.prediction.label)
                        .font(.largeTitle.bold())
                    ResultExplanationCard(prediction: viewModel.prediction)
                }
                recommendations
                actionButtons
                if let message = viewModel.saveMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Result")
        .toolbarTitleDisplayMode(.inline)
    }

    private var recommendations: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommendations")
                .font(.headline)
            Text("Share this report with your optometrist and monitor symptoms daily. Schedule a professional fundus exam if symptoms persist.")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                Task { await viewModel.save() }
            } label: {
                HStack {
                    if viewModel.isSaving { ProgressView() }
                    Text("Save result")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.gradient)
                .foregroundStyle(.white)
                .cornerRadius(16)
            }
            .disabled(viewModel.isSaving)

            if let image = viewModel.image, let data = image.pngData() {
                let shareItem = ScanResultShareItem(data: data)
                ShareLink(item: shareItem, preview: SharePreview("VisioNova Scan Result", image: Image(uiImage: image))) {
                    Label("Share PDF", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).stroke(Color.blue))
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
