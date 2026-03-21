import SwiftUI

struct ScanView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject var viewModel: CameraViewModel
    @State private var showCamera = false
    @State private var navigationPath = NavigationPath()
    @State private var animateScan = false

    init(viewModel: CameraViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color(red: 0.05, green: 0.07, blue: 0.18).ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Preview Area
                    ZStack {
                        if let image = viewModel.capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 32))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(LinearGradient(colors: [.cyan.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .frame(height: 300)
                                .overlay(
                                    VStack(spacing: 12) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 48))
                                            .foregroundStyle(.white.opacity(0.3))
                                        Text("Select or take a photo")
                                            .font(.headline)
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                )
                        }
                        
                        if viewModel.isProcessing {
                            ZStack {
                                Color.black.opacity(0.4)
                                    .clipShape(RoundedRectangle(cornerRadius: 32))
                                
                                VStack(spacing: 20) {
                                    Circle()
                                        .trim(from: 0, to: 0.7)
                                        .stroke(AngularGradient(colors: [.cyan, .blue, .purple], center: .center), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                        .frame(width: 60, height: 60)
                                        .rotationEffect(Angle(degrees: animateScan ? 360 : 0))
                                        .onAppear {
                                            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                                animateScan = true
                                            }
                                        }
                                    
                                    Text("Analyzing Retina...")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    VStack(spacing: 20) {
                        Button {
                            showCamera = true
                        } label: {
                            Label("Take Photo", systemImage: "camera.fill")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                                .foregroundStyle(.white)
                                .cornerRadius(24)
                                .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                        }

                        UploadImagePicker { image in
                            Task { await viewModel.handleImage(image) }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)

                    if let prediction = viewModel.prediction {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("AI Result")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.7))
                                Spacer()
                                Text("\(Int(prediction.confidence * 100))% Confidence")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.cyan)
                            }
                            
                            Text(prediction.label)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Button {
                                navigationPath.append(prediction)
                            } label: {
                                HStack {
                                    Text("View Complete Report")
                                        .fontWeight(.bold)
                                    Image(systemName: "doc.text.fill")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .foregroundStyle(.white)
                                .cornerRadius(16)
                            }
                        }
                        .padding(24)
                        .background(.ultraThinMaterial)
                        .cornerRadius(32)
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer()
                }
            }
            .navigationTitle("Scan")
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationDestination(for: RetinaPrediction.self) { prediction in
                ScanResultView(viewModel: ResultViewModel(prediction: prediction, image: viewModel.capturedImage, sessionStore: appState.sessionStore))
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView(viewModel: viewModel)
        }
    }
}
