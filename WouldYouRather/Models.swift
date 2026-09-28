import Foundation
import SwiftData
import SwiftUI

enum AppLanguage: String, Codable, CaseIterable, Identifiable, Sendable {
    case en
    case zhHans = "zh-Hans"
    case es, pt, fr, de, hi, ar, bn, id, ja, ko, th

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .en: "English"
        case .zhHans: "简体中文"
        case .es: "Español"
        case .pt: "Português"
        case .fr: "Français"
        case .de: "Deutsch"
        case .hi: "हिन्दी"
        case .ar: "العربية"
        case .bn: "বাংলা"
        case .id: "Bahasa Indonesia"
        case .ja: "日本語"
        case .ko: "한국어"
        case .th: "ไทย"
        }
    }

    var isRightToLeft: Bool { self == .ar }
    var isBundled: Bool { self == .en || self == .zhHans }
    var localeLanguage: Locale.Language { Locale.Language(identifier: rawValue) }
    static let storageKey = "preferred-language"

    static var systemDefault: AppLanguage {
        guard let preferred = Locale.preferredLanguages.first else { return .en }
        let candidate = allCases.first {
            preferred.lowercased().hasPrefix($0.rawValue.lowercased())
        } ?? .en
        return TranslationRegistry.releaseLanguages.contains(candidate) ? candidate : .en
    }
}

struct LocalizedValue: Codable, Hashable, Sendable {
    let en: String
    let zhHans: String

    func value(for language: AppLanguage) -> String {
        language == .zhHans ? zhHans : en
    }
}

enum DeckID: String, Codable, CaseIterable, Identifiable, Sendable {
    case love, faith, connection, reflection
    case wisdom, prayer, purpose, courage
    case gratitude, forgiveness, service, hope
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .love: "heart.fill"
        case .faith: "sparkles"
        case .connection: "person.2.fill"
        case .reflection: "water.waves"
        case .wisdom: "lightbulb.fill"
        case .prayer: "hands.clap.fill"
        case .purpose: "scope"
        case .courage: "shield.lefthalf.filled"
        case .gratitude: "sun.max.fill"
        case .forgiveness: "arrow.triangle.2.circlepath"
        case .service: "hand.raised.fill"
        case .hope: "sunrise.fill"
        }
    }

}

struct DeckDefinition: Codable, Identifiable, Hashable, Sendable {
    let id: DeckID
    let title: LocalizedValue
    let summary: LocalizedValue
}

struct BibleReference: Codable, Hashable, Sendable {
    let display: LocalizedValue
    let englishURL: URL
    let chineseURL: URL

    func url(for language: AppLanguage) -> URL {
        language == .zhHans ? chineseURL : englishURL
    }
}

struct QuestionCard: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let deckID: DeckID
    let optionA: LocalizedValue
    let optionB: LocalizedValue
    let context: LocalizedValue
    let reference: BibleReference
}

struct CatalogPayload: Codable, Sendable {
    let decks: [DeckDefinition]
    let cards: [QuestionCard]
}

enum ChoiceOption: String, Codable, Sendable {
    case a, b
}

@Model
final class ChoiceRecord {
    @Attribute(.unique) var id: UUID
    var cardID: String
    var deckID: String
    var selectedOption: String
    var chosenAt: Date
    var localeIdentifier: String
    var questionSnapshot: String
    var optionASnapshot: String
    var optionBSnapshot: String
    var answerSnapshot: String
    var contextSnapshot: String
    var referenceDisplay: String
    var referenceURL: String

    init(
        id: UUID = UUID(),
        card: QuestionCard,
        option: ChoiceOption,
        language: AppLanguage,
        chosenAt: Date = .now
    ) {
        let optionA = card.optionA.value(for: language)
        let optionB = card.optionB.value(for: language)
        self.id = id
        self.cardID = card.id
        self.deckID = card.deckID.rawValue
        self.selectedOption = option.rawValue
        self.chosenAt = chosenAt
        self.localeIdentifier = language.rawValue
        self.questionSnapshot = language == .zhHans
            ? "你愿意\(optionA)，还是\(optionB)？"
            : "Would you rather \(optionA.lowercased()) or \(optionB.lowercased())?"
        self.optionASnapshot = optionA
        self.optionBSnapshot = optionB
        self.answerSnapshot = option == .a ? optionA : optionB
        self.contextSnapshot = card.context.value(for: language)
        self.referenceDisplay = card.reference.display.value(for: language)
        self.referenceURL = card.reference.url(for: language).absoluteString
    }
}

@Model
final class DeckData {
    @Attribute(.unique) var rawID: String
    var titleEN: String
    var titleZH: String
    var summaryEN: String
    var summaryZH: String
    var sortOrder: Int
    var cardCount: Int = 50

    init(_ deck: DeckDefinition, sortOrder: Int, cardCount: Int) {
        rawID = deck.id.rawValue
        titleEN = deck.title.en
        titleZH = deck.title.zhHans
        summaryEN = deck.summary.en
        summaryZH = deck.summary.zhHans
        self.sortOrder = sortOrder
        self.cardCount = cardCount
    }

    var deckID: DeckID? { DeckID(rawValue: rawID) }
    func title(for language: AppLanguage) -> String { language == .zhHans ? titleZH : titleEN }
    func summary(for language: AppLanguage) -> String { language == .zhHans ? summaryZH : summaryEN }
}

@Model
final class CardData {
    @Attribute(.unique) var cardID: String
    var deckRawValue: String
    var optionAEN: String
    var optionAZH: String
    var optionBEN: String
    var optionBZH: String
    var contextEN: String
    var contextZH: String
    var referenceEN: String
    var referenceZH: String
    var englishURL: String
    var chineseURL: String

    init(_ card: QuestionCard) {
        cardID = card.id
        deckRawValue = card.deckID.rawValue
        optionAEN = card.optionA.en
        optionAZH = card.optionA.zhHans
        optionBEN = card.optionB.en
        optionBZH = card.optionB.zhHans
        contextEN = card.context.en
        contextZH = card.context.zhHans
        referenceEN = card.reference.display.en
        referenceZH = card.reference.display.zhHans
        englishURL = card.reference.englishURL.absoluteString
        chineseURL = card.reference.chineseURL.absoluteString
    }

    var questionCard: QuestionCard? {
        guard let deckID = DeckID(rawValue: deckRawValue),
              let englishURL = URL(string: englishURL),
              let chineseURL = URL(string: chineseURL) else { return nil }
        return QuestionCard(
            id: cardID,
            deckID: deckID,
            optionA: .init(en: optionAEN, zhHans: optionAZH),
            optionB: .init(en: optionBEN, zhHans: optionBZH),
            context: .init(en: contextEN, zhHans: contextZH),
            reference: .init(
                display: .init(en: referenceEN, zhHans: referenceZH),
                englishURL: englishURL,
                chineseURL: chineseURL
            )
        )
    }

    func questionCard(using translation: CardTranslationData?) -> QuestionCard? {
        guard let base = questionCard, let translation else { return questionCard }
        let optionA = LocalizedValue(en: translation.optionA, zhHans: translation.optionA)
        let optionB = LocalizedValue(en: translation.optionB, zhHans: translation.optionB)
        let context = LocalizedValue(en: translation.context, zhHans: translation.context)
        let referenceDisplay = LocalizedValue(
            en: translation.referenceDisplay,
            zhHans: translation.referenceDisplay
        )
        return QuestionCard(
            id: base.id,
            deckID: base.deckID,
            optionA: optionA,
            optionB: optionB,
            context: context,
            reference: BibleReference(
                display: referenceDisplay,
                englishURL: base.reference.englishURL,
                chineseURL: base.reference.englishURL
            )
        )
    }
}

@Model
final class CatalogMetadata {
    @Attribute(.unique) var key: String
    var version: Int

    init(key: String = "bundled-catalog", version: Int) {
        self.key = key
        self.version = version
    }
}

@Model
final class DeckTranslationData {
    @Attribute(.unique) var localizationID: String
    var deckID: String
    var languageCode: String
    var title: String
    var summary: String

    init(deckID: String, language: AppLanguage, title: String, summary: String) {
        localizationID = "\(deckID):\(language.rawValue)"
        self.deckID = deckID
        languageCode = language.rawValue
        self.title = title
        self.summary = summary
    }
}

@Model
final class CardTranslationData {
    @Attribute(.unique) var localizationID: String
    var cardID: String
    var languageCode: String
    var optionA: String
    var optionB: String
    var context: String
    var referenceDisplay: String
    var referenceURL: String

    init(
        cardID: String,
        language: AppLanguage,
        optionA: String,
        optionB: String,
        context: String,
        referenceDisplay: String,
        referenceURL: URL
    ) {
        localizationID = "\(cardID):\(language.rawValue)"
        self.cardID = cardID
        languageCode = language.rawValue
        self.optionA = optionA
        self.optionB = optionB
        self.context = context
        self.referenceDisplay = referenceDisplay
        self.referenceURL = referenceURL.absoluteString
    }
}

extension Color {
    static let faithIvory = Color(red: 247 / 255, green: 241 / 255, blue: 231 / 255)
    static let faithIvoryDeep = Color(red: 238 / 255, green: 226 / 255, blue: 208 / 255)
    static let faithPaper = Color(red: 255 / 255, green: 250 / 255, blue: 241 / 255)
    static let faithBackgroundTop = Color(red: 251 / 255, green: 247 / 255, blue: 240 / 255)
    static let faithEspresso = Color(red: 57 / 255, green: 43 / 255, blue: 36 / 255)
    static let faithBrown = Color(red: 90 / 255, green: 70 / 255, blue: 56 / 255)
    static let faithBrownSoft = Color(red: 119 / 255, green: 100 / 255, blue: 87 / 255)
    static let faithGold = Color(red: 183 / 255, green: 138 / 255, blue: 67 / 255)
    static let faithGoldLight = Color(red: 214 / 255, green: 183 / 255, blue: 127 / 255)
    static let faithOlive = Color(red: 91 / 255, green: 90 / 255, blue: 67 / 255)

}
