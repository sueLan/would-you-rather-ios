import Combine
import Foundation

@MainActor
final class ChoiceHistoryStore: ObservableObject {
    @Published private(set) var records: [ChoiceRecord] = []
    private let storage: ChoiceHistoryStorage
    private var pendingOperation: Task<Void, Never>?

    init(fileURL: URL? = nil) {
        storage = ChoiceHistoryStorage(fileURL: fileURL ?? Self.defaultFileURL)
        pendingOperation = Task {
            records = await storage.load()
        }
    }

    /// Waits for initialization and operations already submitted to the store.
    func load() async {
        await pendingOperation?.value
    }

    func append(_ record: ChoiceRecord) async throws {
        try await update { $0.insert(record, at: 0) }
    }

    func delete(id: UUID) async throws {
        try await update { $0.removeAll { $0.id == id } }
    }

    func deleteAll() async throws {
        try await update { $0.removeAll() }
    }

    private func update(_ mutation: @escaping @MainActor @Sendable (inout [ChoiceRecord]) -> Void) async throws {
        let previous = pendingOperation
        let operation = Task { @MainActor in
            await previous?.value
            var updated = records
            mutation(&updated)
            try await storage.save(updated)
            // Publish only after a successful save, so failures need no rollback.
            records = updated
        }
        // Serialize the entire transaction across suspension points. A failed save
        // must not prevent subsequent operations from running.
        pendingOperation = Task { _ = await operation.result }
        try await operation.value
    }

    private static var defaultFileURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("WouldYouRather", isDirectory: true)
        return directory.appendingPathComponent("choice-history.json")
    }
}

/// Actor-isolated synchronous methods keep file I/O off the main actor and
/// prevent storage operations from interleaving while reading or writing.
private actor ChoiceHistoryStorage {
    private let fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func load() -> [ChoiceRecord] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let saved = (try? Data(contentsOf: fileURL)).flatMap {
            try? decoder.decode([ChoiceRecord].self, from: $0)
        } ?? []
        return saved.sorted { $0.chosenAt > $1.chosenAt }
    }

    func save(_ records: [ChoiceRecord]) throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(records)
        try data.write(to: fileURL, options: [.atomic, .completeFileProtectionUnlessOpen])
    }
}
