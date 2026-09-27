import Foundation

enum TranslationRegistry {
    /// A language is exposed in Settings only after its complete catalog has
    /// been reviewed. Update this set when an approved bundle is imported.
    static let reviewedLanguages: Set<AppLanguage> = [.en, .zhHans]

    static var releaseLanguages: [AppLanguage] {
        AppLanguage.allCases.filter(reviewedLanguages.contains)
    }

    static var awaitingReview: [AppLanguage] {
        AppLanguage.allCases.filter { !reviewedLanguages.contains($0) }
    }
}

struct CatalogTranslationBundle: Codable, Sendable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let language: AppLanguage
    let review: TranslationReview
    let decks: [DeckTranslation]
    let cards: [CardTranslation]

    func validate(against payload: CatalogPayload) throws {
        guard schemaVersion == Self.currentSchemaVersion else {
            throw TranslationValidationError.unsupportedSchema(schemaVersion)
        }
        guard review.status == .reviewed else {
            throw TranslationValidationError.notReviewed(language)
        }

        let expectedDeckIDs = Set(payload.decks.map { $0.id.rawValue })
        let actualDeckIDs = Set(decks.map(\.deckID))
        guard decks.count == expectedDeckIDs.count, actualDeckIDs == expectedDeckIDs else {
            throw TranslationValidationError.incompleteDecks(language)
        }

        let expectedCardIDs = Set(payload.cards.map(\.id))
        let actualCardIDs = Set(cards.map(\.cardID))
        guard cards.count == expectedCardIDs.count, actualCardIDs == expectedCardIDs else {
            throw TranslationValidationError.incompleteCards(language)
        }

        guard decks.allSatisfy(\.hasContent), cards.allSatisfy(\.hasContent) else {
            throw TranslationValidationError.emptyText(language)
        }
    }

    static func reviewTemplate(for language: AppLanguage, payload: CatalogPayload) -> Self {
        Self(
            schemaVersion: currentSchemaVersion,
            language: language,
            review: .init(status: .draft, reviewer: nil, reviewedAt: nil),
            decks: payload.decks.map {
                DeckTranslation(
                    deckID: $0.id.rawValue,
                    title: $0.title.en,
                    summary: $0.summary.en
                )
            },
            cards: payload.cards.map {
                CardTranslation(
                    cardID: $0.id,
                    optionA: $0.optionA.en,
                    optionB: $0.optionB.en,
                    context: $0.context.en,
                    referenceDisplay: $0.reference.display.en,
                    referenceURL: $0.reference.englishURL
                )
            }
        )
    }
}

struct TranslationReview: Codable, Sendable {
    enum Status: String, Codable, Sendable { case draft, reviewed }

    let status: Status
    let reviewer: String?
    let reviewedAt: Date?
}

struct DeckTranslation: Codable, Sendable {
    let deckID: String
    let title: String
    let summary: String

    fileprivate var hasContent: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct CardTranslation: Codable, Sendable {
    let cardID: String
    let optionA: String
    let optionB: String
    let context: String
    let referenceDisplay: String
    let referenceURL: URL

    fileprivate var hasContent: Bool {
        [optionA, optionB, context, referenceDisplay].allSatisfy {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}

enum TranslationValidationError: Error, Equatable {
    case unsupportedSchema(Int)
    case notReviewed(AppLanguage)
    case incompleteDecks(AppLanguage)
    case incompleteCards(AppLanguage)
    case emptyText(AppLanguage)
}

enum TranslationBundleLocator {
    static func reviewedBundleURLs(from bundle: Bundle = .main) -> [URL] {
        bundle.urls(forResourcesWithExtension: "json", subdirectory: "Localizations") ?? []
    }
}

actor TranslationBundleDecoder {
    func loadReviewedBundles(from urls: [URL]) throws -> [CatalogTranslationBundle] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try urls.sorted { $0.lastPathComponent < $1.lastPathComponent }.map {
            try decoder.decode(CatalogTranslationBundle.self, from: Data(contentsOf: $0))
        }
    }
}
