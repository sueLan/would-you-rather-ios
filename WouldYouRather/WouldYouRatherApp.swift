import SwiftUI

@main
struct WouldYouRatherApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(appState.historyStore)
                .preferredColorScheme(.light)
        }
    }
}
