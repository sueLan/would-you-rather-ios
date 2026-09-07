import Foundation
import SwiftUI

enum AppLanguage: String, Codable, CaseIterable, Identifiable, Sendable {
    case en
    case zhHans = "zh-Hans"

    var id: String { rawValue }
    var displayName: String { self == .en ? "English" : "简体中文" }

    static var systemDefault: AppLanguage {
        Locale.preferredLanguages.first?.hasPrefix("zh") == true ? .zhHans : .en
    }
}

struct LocalizedValue: Codable, Hashable, Sendable {
    let en: String
    let zhHans: String

    func value(for language: AppLanguage) -> String {
        language == .en ? en : zhHans
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

    var accent: Color {
        switch self {
        case .love: Color(red: 0.68, green: 0.29, blue: 0.34)
        case .faith: Color(red: 0.72, green: 0.53, blue: 0.20)
        case .connection: Color(red: 0.20, green: 0.48, blue: 0.51)
        case .reflection: Color(red: 0.36, green: 0.35, blue: 0.57)
        case .wisdom: Color(red: 0.50, green: 0.39, blue: 0.20)
        case .prayer: Color(red: 0.33, green: 0.42, blue: 0.66)
        case .purpose: Color(red: 0.53, green: 0.30, blue: 0.43)
        case .courage: Color(red: 0.66, green: 0.33, blue: 0.22)
        case .gratitude: Color(red: 0.72, green: 0.48, blue: 0.16)
        case .forgiveness: Color(red: 0.28, green: 0.52, blue: 0.40)
        case .service: Color(red: 0.31, green: 0.43, blue: 0.48)
        case .hope: Color(red: 0.42, green: 0.47, blue: 0.68)
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
        language == .en ? englishURL : chineseURL
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

struct ChoiceRecord: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let cardID: String
    let deckID: String
    let selectedOption: String
    let chosenAt: Date
    let localeIdentifier: String
    let questionSnapshot: String
    let optionASnapshot: String
    let optionBSnapshot: String
    let answerSnapshot: String
    let contextSnapshot: String
    let referenceDisplay: String
    let referenceURL: String

    init(
        id: UUID = UUID(),
        card: QuestionCard,
        deckTitle: String,
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
        self.questionSnapshot = language == .en
            ? "Would you rather \(optionA.lowercased()) or \(optionB.lowercased())?"
            : "你愿意\(optionA)，还是\(optionB)？"
        self.optionASnapshot = optionA
        self.optionBSnapshot = optionB
        self.answerSnapshot = option == .a ? optionA : optionB
        self.contextSnapshot = card.context.value(for: language)
        self.referenceDisplay = card.reference.display.value(for: language)
        self.referenceURL = card.reference.url(for: language).absoluteString
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

    // Compatibility aliases used by existing components.
    static let faithNavy = faithBrown
    static let faithInk = faithEspresso
}
