import SwiftUI

struct CameraView: View {
    @ObservedObject var viewModel: CameraViewModel
    @Environment(
        \.dismiss
    ) private var dismiss
    @State private var isTorchOn = false

    var body: some View {
        ZStack {
            CameraPreview(service: viewModel.captureService)
                .ignoresSafeArea()
                .onAppear { viewModel.startSession() }
                .onDisappear { viewModel.stopSession() }

            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Button(action: toggleTorch) {
                        Image(systemName: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.title2)
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding()
                Spacer()
                captureControls
            }
        }
    }

    private var captureControls: some View {
        HStack {
            Spacer()
            Button(action: viewModel.capturePhoto) {
                Circle()
                    .strokeBorder(.white, lineWidth: 4)
                    .frame(width: 80, height: 80)
                    .overlay(Circle().fill(.white).padding(8))
                    .padding(.bottom, 32)
            }
            Spacer()
        }
    }

    private func toggleTorch() {
        isTorchOn.toggle()
        viewModel.captureService.toggleTorch()
    }
}
