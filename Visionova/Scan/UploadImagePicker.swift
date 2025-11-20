import SwiftUI
import PhotosUI
import UIKit

struct UploadImagePicker: View {
    @State private var pickerItem: PhotosPickerItem?
    let onImagePicked: (UIImage) -> Void

    var body: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            Label("Upload Photo", systemImage: "photo.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        }
        .onChange(of: pickerItem) { _, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        onImagePicked(image)
                    }
                }
            }
        }
    }
}
