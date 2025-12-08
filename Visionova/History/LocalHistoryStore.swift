import Foundation
import UIKit

struct LocalScanRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let createdAt: Date
    let imagePath: String? // relative file name in Documents
    let prediction: String
    let confidence: Double
    let explanation: String
}

final class LocalHistoryStore {
    static let shared = LocalHistoryStore()

    private let fileName = "scan_history.json"
    private init() {}

    // MARK: - Public API

    func load() -> [LocalScanRecord] {
        guard let url = historyURL(), let data = try? Data(contentsOf: url) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([LocalScanRecord].self, from: data)) ?? []
    }

    func save(records: [LocalScanRecord]) {
        guard let url = historyURL() else { return }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(records) {
            try? data.write(to: url, options: .atomic)
        }
    }

    func append(image: UIImage?, prediction: String, confidence: Double, explanation: String) -> LocalScanRecord {
        var records = load()
        let id = UUID()
        let imageFile = saveImageIfNeeded(id: id, image: image)
        let record = LocalScanRecord(id: id, createdAt: Date(), imagePath: imageFile, prediction: prediction, confidence: confidence, explanation: explanation)
        records.insert(record, at: 0)
        save(records: records)
        return record
    }

    func delete(id: UUID) {
        var records = load()
        if let idx = records.firstIndex(where: { $0.id == id }) {
            if let path = records[idx].imagePath { deleteImage(fileName: path) }
            records.remove(at: idx)
            save(records: records)
        }
    }

    // MARK: - Helpers

    private func documentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    private func historyURL() -> URL? {
        documentsDirectory()?.appendingPathComponent(fileName)
    }

    private func imageURL(for fileName: String) -> URL? {
        documentsDirectory()?.appendingPathComponent(fileName)
    }

    private func saveImageIfNeeded(id: UUID, image: UIImage?) -> String? {
        guard let image, let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        let fileName = "scan_\(id.uuidString).jpg"
        if let url = imageURL(for: fileName) {
            try? data.write(to: url, options: .atomic)
            return fileName
        }
        return nil
    }

    private func deleteImage(fileName: String) {
        guard let url = imageURL(for: fileName) else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
