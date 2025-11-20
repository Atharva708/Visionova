import UIKit

final class ImageUtils {
    static let shared = ImageUtils()
    private init() {}

    func persistTemporaryPNG(_ image: UIImage) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("scan-\(UUID().uuidString).png")
        guard let data = image.pngData() else { return nil }
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }
}
