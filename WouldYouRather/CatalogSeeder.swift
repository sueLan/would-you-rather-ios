import SwiftData

@ModelActor
actor CatalogSeeder {
    static let currentVersion = 1

    func seedIfNeeded(payload: CatalogPayload, version: Int) throws {
        let metadata = try modelContext.fetch(FetchDescriptor<CatalogMetadata>()).first
        guard metadata?.version != version else { return }

        try modelContext.delete(model: CardData.self)
        try modelContext.delete(model: DeckData.self)

        for (index, deck) in payload.decks.enumerated() {
            modelContext.insert(DeckData(deck, sortOrder: index))
        }
        for card in payload.cards {
            modelContext.insert(CardData(card))
        }

        if let metadata {
            metadata.version = version
        } else {
            modelContext.insert(CatalogMetadata(version: version))
        }
        try modelContext.save()
    }
}
