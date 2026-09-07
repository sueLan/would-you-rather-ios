import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            DeckListView()
        }
        .tint(Color.faithGold)
    }
}

struct DeckListView: View {
    @EnvironmentObject private var appState: AppState
    private let columns = [GridItem(.adaptive(minimum: 260), spacing: 18)]

    var body: some View {
        ZStack {
            FaithBackdrop()

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 14) {
                        BrandLockupView(language: appState.language)

                        Spacer(minLength: 8)

                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(Color.faithGold)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(t(.settings))
                    }
                        .padding(.bottom, 18)

                    Text(t(.decks).uppercased())
                        .font(.caption2.weight(.semibold))
                        .tracking(1.6)
                        .foregroundStyle(Color.faithGold)

                    LazyVGrid(columns: columns, spacing: 18) {
                        ForEach(appState.catalog.decks) { deck in
                            NavigationLink(value: deck.id) {
                                DeckTile(deck: deck, cardCount: appState.cards(in: deck.id).count)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: DeckID.self) { deckID in
            CardSessionView(deckID: deckID)
        }
    }

    private func t(_ key: Strings.Key) -> String { Strings.text(key, appState.language) }
}

private struct DeckTile: View {
    @EnvironmentObject private var appState: AppState
    let deck: DeckDefinition
    let cardCount: Int

    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: deck.id.symbol)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.faithGold)
                .frame(width: 54, height: 54)
                .background(Color.faithGoldLight.opacity(0.17), in: Circle())
                .overlay {
                    Circle().stroke(Color.faithGold.opacity(0.28), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 5) {
                Text(deck.title.value(for: appState.language))
                    .font(.system(.title3, design: .serif, weight: .semibold))
                    .foregroundStyle(Color.faithEspresso)
                Text(deck.summary.value(for: appState.language))
                    .font(.subheadline)
                    .foregroundStyle(Color.faithBrownSoft)
                    .lineLimit(2)
                Text(Strings.text(.cards(cardCount), appState.language))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.faithGold)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.faithBrownSoft)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
        .parchmentPanel(cornerRadius: 18)
        .overlay { OrnamentalCorners(inset: 8, length: 14).opacity(0.55) }
        .accessibilityElement(children: .combine)
    }
}

private struct DecksPreview: PreviewProvider {
    @MainActor
    static var previews: some View {
        let historyStore = ChoiceHistoryStore(
            fileURL: FileManager.default.temporaryDirectory
                .appendingPathComponent("preview-history.json")
        )
        let appState = AppState(historyStore: historyStore)

        RootView()
            .environmentObject(appState)
            .environmentObject(historyStore)
            .previewDisplayName("Decks")
    }
}
