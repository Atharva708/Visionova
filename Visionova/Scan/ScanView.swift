import SwiftUI

struct ScanView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject var viewModel: CameraViewModel
    @State private var showCamera = false
    @State private var navigationPath = NavigationPath()

    init(viewModel: CameraViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 24) {
                if let image = viewModel.capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 220)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.purple.opacity(0.3), lineWidth: 2))
                } else {
                    Rectangle()
                        .fill(Color(.secondarySystemBackground))
                        .frame(height: 220)
                        .overlay(Text("No image selected").foregroundStyle(.secondary))
                        .cornerRadius(20)
                }

                VStack(spacing: 16) {
                    Button {
                        showCamera = true
                    } label: {
                        Label("Take Photo", systemImage: "camera.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.gradient)
                            .foregroundStyle(.white)
                            .cornerRadius(16)
                    }

                    UploadImagePicker { image in
                        Task { await viewModel.handleImage(image) }
                    }
                }

                if viewModel.isProcessing {
                    VStack(spacing: 12) {
                        ProgressView("Analyzing image...")
                        Text("This takes a few seconds")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
                }

                if let prediction = viewModel.prediction {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AI Result")
                            .font(.headline)
                        Text(prediction.label)
                            .font(.title2.bold())
                        ProgressView(value: prediction.confidence)
                        Text("Confidence: \(Int(prediction.confidence * 100))%")
                        Button("View Report") {
                            navigationPath.append(prediction)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Scan")
            .navigationDestination(for: RetinaPrediction.self) { prediction in
                ScanResultView(viewModel: ResultViewModel(prediction: prediction, image: viewModel.capturedImage, sessionStore: appState.sessionStore))
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView(viewModel: viewModel)
        }
    }
}
