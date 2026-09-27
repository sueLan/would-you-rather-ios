import SwiftUI
import SwiftData

@main
struct WouldYouRatherApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: DeckData.self,
                CardData.self,
                ChoiceRecord.self,
                CatalogMetadata.self
            )
        } catch {
            fatalError("Unable to create the data store: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
                .task {
                    let seeder = CatalogSeeder(modelContainer: modelContainer)
                    try? await seeder.seedIfNeeded(
                        payload: ContentCatalog.payload,
                        version: CatalogSeeder.currentVersion
                    )
                }
        }
        .modelContainer(modelContainer)
    }
}
