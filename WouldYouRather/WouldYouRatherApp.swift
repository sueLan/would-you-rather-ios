import SwiftUI
import SwiftData

@main
struct WouldYouRatherApp: App {
    private let modelContainer: ModelContainer
    @State private var startupFailure: StartupFailure?

    init() {
        do {
            modelContainer = try ModelContainer(
                for: DeckData.self,
                CardData.self,
                DeckTranslationData.self,
                CardTranslationData.self,
                ChoiceRecord.self,
                CatalogMetadata.self
            )
            _startupFailure = State(initialValue: nil)
        } catch {
            do {
                let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
                modelContainer = try ModelContainer(
                    for: DeckData.self,
                    CardData.self,
                    DeckTranslationData.self,
                    CardTranslationData.self,
                    ChoiceRecord.self,
                    CatalogMetadata.self,
                    configurations: configuration
                )
                _startupFailure = State(initialValue: StartupFailure(
                    message: error.localizedDescription,
                    canRetry: false
                ))
            } catch {
                fatalError("Unable to create a persistent or temporary data store: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
                .task {
                    await seedCatalog()
                }
                .alert(item: $startupFailure) { failure in
                    Alert(
                        title: Text(Strings.text(.dataUnavailable, currentLanguage)),
                        message: Text(failure.canRetry
                                      ? failure.message
                                      : Strings.text(.temporaryStorageBody, currentLanguage)),
                        primaryButton: failure.canRetry
                            ? .default(Text(Strings.text(.retry, currentLanguage))) {
                                Task { await seedCatalog() }
                            }
                            : .default(Text(Strings.text(.ok, currentLanguage))),
                        secondaryButton: .cancel(Text(Strings.text(.cancel, currentLanguage)))
                    )
                }
        }
        .modelContainer(modelContainer)
    }

    @AppStorage(AppLanguage.storageKey) private var languageRawValue = AppLanguage.systemDefault.rawValue
    private var currentLanguage: AppLanguage {
        AppLanguage(rawValue: languageRawValue) ?? .systemDefault
    }

    @MainActor
    private func seedCatalog() async {
        do {
            let seeder = CatalogSeeder(modelContainer: modelContainer)
            try await seeder.seedDecksIfNeeded(
                decks: ContentCatalog.decks,
                version: CatalogSeeder.deckVersion
            )
            await Task.yield()
            let translationURLs = TranslationBundleLocator.reviewedBundleURLs()
            let reviewedBundles = try await TranslationBundleDecoder()
                .loadReviewedBundles(from: translationURLs)
            try await seeder.seedCardsIfNeeded(
                version: CatalogSeeder.cardVersion,
                reviewedBundles: reviewedBundles
            )
            if startupFailure?.canRetry == true { startupFailure = nil }
        } catch {
            startupFailure = StartupFailure(message: error.localizedDescription, canRetry: true)
        }
    }
}

private struct StartupFailure: Identifiable {
    let id = UUID()
    let message: String
    let canRetry: Bool
}
