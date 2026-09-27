import SwiftUI
import SwiftData

struct RootView: View {
    var body: some View {
        NavigationStack {
            DeckListView()
        }
        .tint(Color.faithGold)
    }
}

struct DeckListView: View {
    @Query(sort: \DeckData.sortOrder) private var decks: [DeckData]
    @Query private var cards: [CardData]
    @AppStorage(AppLanguage.storageKey) private var languageRawValue = AppLanguage.systemDefault.rawValue
    private let columns = [GridItem(.adaptive(minimum: 260), spacing: 18)]
    private var language: AppLanguage { AppLanguage(rawValue: languageRawValue) ?? .systemDefault }

    var body: some View {
        ZStack {
            FaithBackdrop()

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 14) {
                        BrandLockupView(language: language)

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
                        ForEach(decks) { deck in
                            if let deckID = deck.deckID {
                                NavigationLink(value: deckID) {
                                    DeckTile(
                                        deck: deck,
                                        cardCount: cards.lazy.filter { $0.deckRawValue == deck.rawID }.count,
                                        language: language
                                    )
                                }
                                .buttonStyle(.plain)
                            }
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

    private func t(_ key: Strings.Key) -> String { Strings.text(key, language) }
}

private struct DeckTile: View {
    let deck: DeckData
    let cardCount: Int
    let language: AppLanguage

    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: deck.deckID?.symbol ?? "rectangle.stack")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.faithGold)
                .frame(width: 54, height: 54)
                .background(Color.faithGoldLight.opacity(0.17), in: Circle())
                .overlay {
                    Circle().stroke(Color.faithGold.opacity(0.28), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 5) {
                Text(deck.title(for: language))
                    .font(.system(.title3, design: .serif, weight: .semibold))
                    .foregroundStyle(Color.faithEspresso)
                Text(deck.summary(for: language))
                    .font(.subheadline)
                    .foregroundStyle(Color.faithBrownSoft)
                    .lineLimit(2)
                Text(Strings.text(.cards(cardCount), language))
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
        RootView()
            .modelContainer(for: [DeckData.self, CardData.self, ChoiceRecord.self, CatalogMetadata.self], inMemory: true)
            .previewDisplayName("Decks")
    }
}
