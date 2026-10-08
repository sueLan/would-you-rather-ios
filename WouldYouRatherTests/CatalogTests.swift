import XCTest
import SwiftData
@testable import WouldYouRather

final class CatalogTests: XCTestCase {
    func testCatalogHasMoreThanTenDecksAndFiftyCardsEach() {
        XCTAssertGreaterThan(ContentCatalog.payload.decks.count, 10)
        XCTAssertEqual(ContentCatalog.payload.decks.count, DeckID.allCases.count)
        XCTAssertEqual(Set(ContentCatalog.payload.decks.map(\.id)), Set(DeckID.allCases))
        XCTAssertEqual(ContentCatalog.payload.cards.count, DeckID.allCases.count * 50)
        for deck in DeckID.allCases {
            let cards = ContentCatalog.payload.cards.filter { $0.deckID == deck }
            XCTAssertEqual(cards.count, 50, "\(deck.rawValue) must contain 50 cards")
            XCTAssertEqual(
                Set(cards.map { "\($0.optionA.en)|\($0.optionB.en)" }).count,
                50,
                "\(deck.rawValue) must not repeat a choice pair"
            )
            XCTAssertEqual(
                Set(cards.map { "\($0.optionA.zhHans)|\($0.optionB.zhHans)" }).count,
                50,
                "\(deck.rawValue) must not repeat a Chinese choice pair"
            )
        }
    }

    func testCardIDsAreUniqueAndLocalizedValuesArePresent() {
        let cards = ContentCatalog.payload.cards
        XCTAssertEqual(Set(cards.map(\.id)).count, cards.count)
        for card in cards {
            XCTAssertFalse(card.optionA.en.isEmpty)
            XCTAssertFalse(card.optionA.zhHans.isEmpty)
            XCTAssertFalse(card.optionB.en.isEmpty)
            XCTAssertFalse(card.optionB.zhHans.isEmpty)
            XCTAssertFalse(card.context.en.isEmpty)
            XCTAssertFalse(card.context.zhHans.isEmpty)
        }
    }

    func testBibleLinksAreHTTPSAndUseExpectedTranslations() {
        for card in ContentCatalog.payload.cards {
            let references = card.scriptureReferences
            XCTAssertGreaterThanOrEqual(references.count, 3)
            XCTAssertLessThanOrEqual(references.count, 5)
            XCTAssertEqual(Set(references.map(\.englishURL)).count, references.count)

            for reference in references {
                let english = reference.englishURL
                let chinese = reference.chineseURL
                XCTAssertEqual(english.scheme, "https")
                XCTAssertEqual(english.host, "www.bible.com")
                XCTAssertTrue(english.path.contains("/bible/111/"))
                XCTAssertTrue(english.absoluteString.hasSuffix(".NIV"))
                XCTAssertEqual(chinese.scheme, "https")
                XCTAssertEqual(chinese.host, "www.bible.com")
                XCTAssertTrue(chinese.path.contains("/bible/48/"))
                XCTAssertTrue(chinese.absoluteString.contains("CUNPSS"))
            }
        }
    }

    func testTranslationRegistryIncludesRequestedLanguagesButReleasesOnlyReviewedOnes() {
        XCTAssertEqual(AppLanguage.allCases.count, 13)
        XCTAssertEqual(Set(TranslationRegistry.releaseLanguages), [.en, .zhHans])
        XCTAssertEqual(
            Set(TranslationRegistry.awaitingReview),
            [.es, .pt, .fr, .de, .hi, .ar, .bn, .id, .ja, .ko, .th]
        )
        XCTAssertTrue(AppLanguage.ar.isRightToLeft)
        XCTAssertFalse(AppLanguage.de.isRightToLeft)
    }

    func testUnreviewedLanguagesUseEnglishUntilATranslationIsCached() throws {
        let card = try XCTUnwrap(ContentCatalog.payload.cards.first)
        XCTAssertEqual(card.optionA.value(for: .de), card.optionA.en)
        XCTAssertEqual(card.context.value(for: .ja), card.context.en)
        XCTAssertEqual(card.reference.url(for: .th), card.reference.englishURL)
        XCTAssertEqual(Strings.text(.settings, .es), Strings.text(.settings, .en))
    }

    func testTranslationTemplateContainsEveryDeckAndCardAndRequiresReview() throws {
        let template = CatalogTranslationBundle.reviewTemplate(
            for: .de,
            payload: ContentCatalog.payload
        )
        XCTAssertEqual(template.decks.count, 12)
        XCTAssertEqual(template.cards.count, 600)
        XCTAssertThrowsError(try template.validate(against: ContentCatalog.payload)) { error in
            XCTAssertEqual(error as? TranslationValidationError, .notReviewed(.de))
        }
    }

    @MainActor
    func testHistoryPersistenceAndDeletion() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let card = try XCTUnwrap(ContentCatalog.payload.cards.first)
        let record = ChoiceRecord(
            id: UUID(),
            card: card,
            option: .a,
            language: .en,
            chosenAt: Date(timeIntervalSince1970: 1_700_000_000)
        )

        context.insert(record)
        try context.save()
        var saved = try context.fetch(FetchDescriptor<ChoiceRecord>())
        XCTAssertEqual(saved.map(\.id), [record.id])

        context.delete(record)
        try context.save()
        saved = try context.fetch(FetchDescriptor<ChoiceRecord>())
        XCTAssertTrue(saved.isEmpty)
    }

    @MainActor
    func testCatalogSeederPersistsDecksAndCardsOnce() async throws {
        let container = try makeContainer()
        let seeder = CatalogSeeder(modelContainer: container)

        try await seeder.seedDecksIfNeeded(
            decks: ContentCatalog.decks,
            version: 1
        )
        let metadataOnlyCounts = try await CatalogProbe(modelContainer: container).counts()
        XCTAssertEqual(metadataOnlyCounts.decks, DeckID.allCases.count)
        XCTAssertEqual(metadataOnlyCounts.cards, 0)
        XCTAssertEqual(metadataOnlyCounts.deckTranslations, DeckID.allCases.count * 2)
        XCTAssertEqual(metadataOnlyCounts.cardTranslations, 0)
        XCTAssertEqual(metadataOnlyCounts.metadata, 1)

        try await seeder.seedIfNeeded(
            payload: ContentCatalog.payload,
            deckVersion: 1,
            cardVersion: 1
        )
        try await seeder.seedIfNeeded(
            payload: ContentCatalog.payload,
            deckVersion: 1,
            cardVersion: 1
        )

        let counts = try await CatalogProbe(modelContainer: container).counts()
        XCTAssertEqual(counts.decks, DeckID.allCases.count)
        XCTAssertEqual(counts.cards, DeckID.allCases.count * 50)
        XCTAssertEqual(counts.deckTranslations, DeckID.allCases.count * 2)
        XCTAssertEqual(counts.cardTranslations, DeckID.allCases.count * 50 * 2)
        XCTAssertEqual(counts.metadata, 2)
    }

    @MainActor
    func testCatalogUpgradeRefreshesCardsAndPreservesHistory() async throws {
        let container = try makeContainer()
        let seeder = CatalogSeeder(modelContainer: container)
        let updated = try XCTUnwrap(ContentCatalog.cards.first)
        let old = QuestionCard(
            id: updated.id, deckID: updated.deckID,
            optionA: .init(en: "Old choice", zhHans: "旧选项"),
            optionB: updated.optionB, context: updated.context, reference: updated.reference
        )
        try await seeder.seedIfNeeded(
            payload: CatalogPayload(decks: ContentCatalog.decks, cards: [old]),
            deckVersion: CatalogSeeder.deckVersion, cardVersion: 3
        )
        let history = ChoiceRecord(card: old, option: .a, language: .en)
        container.mainContext.insert(history)
        try container.mainContext.save()

        try await seeder.seedIfNeeded(
            payload: ContentCatalog.payload,
            deckVersion: CatalogSeeder.deckVersion, cardVersion: CatalogSeeder.cardVersion
        )
        let cards = try container.mainContext.fetch(FetchDescriptor<CardData>())
        XCTAssertEqual(cards.count, 600)
        XCTAssertEqual(cards.first { $0.cardID == updated.id }?.optionAEN, updated.optionA.en)
        let records = try container.mainContext.fetch(FetchDescriptor<ChoiceRecord>())
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.optionASnapshot, "Old choice")
    }

    func testUpdatedCardsIncludeBothChoiceScriptures() throws {
        let card = try XCTUnwrap(ContentCatalog.cards.first { $0.id == "love-01" })
        XCTAssertEqual(card.optionA.en, "Invite a new church member to a meal")
        XCTAssertEqual(card.optionB.zhHans, "帮助教会的新朋友认识一个小组")
        XCTAssertEqual(card.scriptureReferences[0].display.en, "Romans 12:13")
        XCTAssertEqual(card.scriptureReferences[1].display.en, "Hebrews 10:24–25")
    }

    @MainActor
    private func makeContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: DeckData.self,
            CardData.self,
            DeckTranslationData.self,
            CardTranslationData.self,
            ChoiceRecord.self,
            CatalogMetadata.self,
            configurations: configuration
        )
    }
}

@ModelActor
private actor CatalogProbe {
    func counts() throws -> (
        decks: Int,
        cards: Int,
        deckTranslations: Int,
        cardTranslations: Int,
        metadata: Int
    ) {
        (
            try modelContext.fetchCount(FetchDescriptor<DeckData>()),
            try modelContext.fetchCount(FetchDescriptor<CardData>()),
            try modelContext.fetchCount(FetchDescriptor<DeckTranslationData>()),
            try modelContext.fetchCount(FetchDescriptor<CardTranslationData>()),
            try modelContext.fetchCount(FetchDescriptor<CatalogMetadata>())
        )
    }
}
