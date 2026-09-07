import XCTest
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
            XCTAssertLessThanOrEqual(references.count, 4)
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

    @MainActor
    func testHistoryStoreRoundTripAndDeletion() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("history-\(UUID().uuidString).json")
        let card = try XCTUnwrap(ContentCatalog.payload.cards.first)
        let record = ChoiceRecord(
            id: UUID(),
            card: card,
            deckTitle: "Love",
            option: .a,
            language: .en,
            chosenAt: Date(timeIntervalSince1970: 1_700_000_000)
        )

        let store = ChoiceHistoryStore(fileURL: fileURL)
        try store.append(record)
        XCTAssertEqual(store.records, [record])

        let reloaded = ChoiceHistoryStore(fileURL: fileURL)
        XCTAssertEqual(reloaded.records, [record])
        try reloaded.delete(id: record.id)
        XCTAssertTrue(reloaded.records.isEmpty)
        try? FileManager.default.removeItem(at: fileURL)
    }
}
