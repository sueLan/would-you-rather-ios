import Combine
import Foundation

@MainActor
final class ChoiceHistoryStore: ObservableObject {
    @Published private(set) var records: [ChoiceRecord] = []
    private let fileURL: URL

    init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? Self.defaultFileURL
        load()
    }

    func append(_ record: ChoiceRecord) throws {
        records.insert(record, at: 0)
        do {
            try persist()
        } catch {
            records.removeAll { $0.id == record.id }
            throw error
        }
    }

    func delete(id: UUID) throws {
        let previous = records
        records.removeAll { $0.id == id }
        do {
            try persist()
        } catch {
            records = previous
            throw error
        }
    }

    func deleteAll() throws {
        let previous = records
        records.removeAll()
        do {
            try persist()
        } catch {
            records = previous
            throw error
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let saved = try? decoder.decode([ChoiceRecord].self, from: data) else { return }
        records = saved.sorted { $0.chosenAt > $1.chosenAt }
    }

    private func persist() throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(records)
        try data.write(to: fileURL, options: [.atomic, .completeFileProtectionUnlessOpen])
    }

    private static var defaultFileURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("WouldYouRather", isDirectory: true)
        return directory.appendingPathComponent("choice-history.json")
    }
}
