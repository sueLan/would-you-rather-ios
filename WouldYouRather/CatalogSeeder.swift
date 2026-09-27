import SwiftData

@ModelActor
actor CatalogSeeder {
    static let deckVersion = 1
    static let cardVersion = 3

    func seedDecksIfNeeded(decks: [DeckDefinition], version: Int) throws {
        guard try storedVersion(for: "deck-catalog") != version else { return }

        try modelContext.delete(model: DeckData.self)
        try modelContext.delete(model: DeckTranslationData.self)

        for (index, deck) in decks.enumerated() {
            modelContext.insert(DeckData(deck, sortOrder: index, cardCount: 50))
            modelContext.insert(DeckTranslationData(
                deckID: deck.id.rawValue,
                language: .en,
                title: deck.title.en,
                summary: deck.summary.en
            ))
            modelContext.insert(DeckTranslationData(
                deckID: deck.id.rawValue,
                language: .zhHans,
                title: deck.title.zhHans,
                summary: deck.summary.zhHans
            ))
        }

        try setStoredVersion(version, for: "deck-catalog")
        try modelContext.save()
    }

    func seedCardsIfNeeded(
        version: Int,
        reviewedBundles: [CatalogTranslationBundle]
    ) throws {
        guard try storedVersion(for: "card-catalog") != version else { return }
        let payload = ContentCatalog.payload
        try seedCards(payload: payload, reviewedBundles: reviewedBundles, version: version)
    }

    func seedIfNeeded(
        payload: CatalogPayload,
        deckVersion: Int,
        cardVersion: Int,
        reviewedBundles: [CatalogTranslationBundle] = []
    ) throws {
        try seedDecksIfNeeded(decks: payload.decks, version: deckVersion)
        guard try storedVersion(for: "card-catalog") != cardVersion else { return }
        try seedCards(payload: payload, reviewedBundles: reviewedBundles, version: cardVersion)
    }

    private func seedCards(
        payload: CatalogPayload,
        reviewedBundles: [CatalogTranslationBundle],
        version: Int
    ) throws {
        try modelContext.delete(model: CardData.self)
        try modelContext.delete(model: CardTranslationData.self)

        for card in payload.cards {
            modelContext.insert(CardData(card))
            modelContext.insert(CardTranslationData(
                cardID: card.id,
                language: .en,
                optionA: card.optionA.en,
                optionB: card.optionB.en,
                context: card.context.en,
                referenceDisplay: card.reference.display.en,
                referenceURL: card.reference.englishURL
            ))
            modelContext.insert(CardTranslationData(
                cardID: card.id,
                language: .zhHans,
                optionA: card.optionA.zhHans,
                optionB: card.optionB.zhHans,
                context: card.context.zhHans,
                referenceDisplay: card.reference.display.zhHans,
                referenceURL: card.reference.chineseURL
            ))
        }

        for bundle in reviewedBundles {
            try bundle.validate(against: payload)
            for deck in bundle.decks {
                modelContext.insert(DeckTranslationData(
                    deckID: deck.deckID,
                    language: bundle.language,
                    title: deck.title,
                    summary: deck.summary
                ))
            }
            for card in bundle.cards {
                modelContext.insert(CardTranslationData(
                    cardID: card.cardID,
                    language: bundle.language,
                    optionA: card.optionA,
                    optionB: card.optionB,
                    context: card.context,
                    referenceDisplay: card.referenceDisplay,
                    referenceURL: card.referenceURL
                ))
            }
        }

        try setStoredVersion(version, for: "card-catalog")
        try modelContext.save()
    }

    private func storedVersion(for key: String) throws -> Int? {
        try modelContext.fetch(FetchDescriptor<CatalogMetadata>())
            .first { $0.key == key }?.version
    }

    private func setStoredVersion(_ version: Int, for key: String) throws {
        let metadata = try modelContext.fetch(FetchDescriptor<CatalogMetadata>())
            .first { $0.key == key }
        if let metadata {
            metadata.version = version
        } else {
            modelContext.insert(CatalogMetadata(key: key, version: version))
        }
    }
}
