import Foundation

/// The reviewed bilingual card catalog shared with Android.
enum CatalogExpansion {
    private struct BundledCard: Decodable {
        let id: String
        let deckID: DeckID
        let optionA: LocalizedValue
        let optionB: LocalizedValue
        let context: LocalizedValue
        let reference: BibleReference
        let supportingReferences: [BibleReference]

        var question: QuestionCard {
            QuestionCard(
                id: id, deckID: deckID, optionA: optionA, optionB: optionB,
                context: context, reference: reference
            )
        }
    }

    private struct BundlePayload: Decodable {
        let cards: [BundledCard]
    }

    private static let bundledCards: [BundledCard] = {
        guard let url = Bundle.main.url(forResource: "catalog", withExtension: "json") else {
            preconditionFailure("Missing bundled card catalog")
        }
        do {
            return try JSONDecoder().decode(BundlePayload.self, from: Data(contentsOf: url)).cards
        } catch {
            preconditionFailure("Invalid bundled card catalog: \(error)")
        }
    }()

    static let cards = bundledCards.map(\.question)
    static let supportingReferences = Dictionary(uniqueKeysWithValues:
        bundledCards.map { ($0.id, $0.supportingReferences) }
    )
}
