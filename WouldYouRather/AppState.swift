import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
    let catalog: CatalogPayload
    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Self.languageKey) }
    }
    @Published var globalError: String?
    let historyStore: ChoiceHistoryStore

    private static let languageKey = "preferred-language"

    init(catalog: CatalogPayload = ContentCatalog.payload, historyStore: ChoiceHistoryStore? = nil) {
        self.catalog = catalog
        self.historyStore = historyStore ?? ChoiceHistoryStore()
        if let saved = UserDefaults.standard.string(forKey: Self.languageKey),
           let language = AppLanguage(rawValue: saved) {
            self.language = language
        } else {
            self.language = .systemDefault
        }
    }

    func deck(_ id: DeckID) -> DeckDefinition {
        catalog.decks.first(where: { $0.id == id })!
    }

    func cards(in deckID: DeckID) -> [QuestionCard] {
        catalog.cards.filter { $0.deckID == deckID }
    }
}
