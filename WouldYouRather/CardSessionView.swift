import SwiftUI
import SwiftData
import UIKit

struct CardSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query private var persistedCards: [CardData]
    @Query private var persistedDecks: [DeckData]
    @AppStorage(AppLanguage.storageKey) private var languageRawValue = AppLanguage.systemDefault.rawValue

    let deckID: DeckID
    @State private var cardIDs: [String] = []
    @State private var index = 0
    @State private var dragOffset: CGSize = .zero
    @State private var cardOpacity = 1.0
    @State private var cardScale = 1.0
    @State private var cardTravelDistance = 500.0
    @State private var selectedOption: ChoiceOption?
    @State private var isTransitioning = false
    @State private var contextCard: QuestionCard?
    @State private var saveError: String?

    private var language: AppLanguage { AppLanguage(rawValue: languageRawValue) ?? .systemDefault }
    private var deck: DeckData? { persistedDecks.first { $0.rawID == deckID.rawValue } }
    private var currentCard: QuestionCard? {
        guard cardIDs.indices.contains(index) else { return nil }
        return persistedCards.first { $0.cardID == cardIDs[index] }?.questionCard
    }

    var body: some View {
        ZStack {
            FaithBackdrop()

            if cardIDs.isEmpty {
                ProgressView().tint(Color.faithIvory)
            } else if index >= cardIDs.count {
                completionView
            } else if let card = currentCard {
                cardExperience(card)
            }
        }
        .navigationTitle(deck?.title(for: language) ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbarBackground(Color.faithPaper.opacity(0.78), for: .navigationBar)
        .onAppear { if cardIDs.isEmpty { shuffle() } }
        .onChange(of: persistedCards.count) { _, _ in
            if cardIDs.isEmpty { shuffle() }
        }
        .sheet(item: $contextCard) { card in
            BiblicalContextView(card: card)
        }
        .alert(t(.unableToSave), isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button(t(.ok), role: .cancel) { saveError = nil }
        } message: {
            Text(saveError ?? "")
        }
    }

    @ViewBuilder
    private func cardExperience(_ card: QuestionCard) -> some View {
        GeometryReader { proxy in
            VStack(spacing: 12) {
                HStack {
                    Label {
                        Text((deck?.title(for: language) ?? "").uppercased())
                    } icon: {
                        Image(systemName: "sparkle")
                            .foregroundStyle(Color.faithGold)
                    }
                    .font(.caption2.weight(.semibold))
                    .tracking(1.1)

                    Spacer()

                    Text(String(format: "%02d / %02d", index + 1, cardIDs.count))
                        .font(.caption.monospacedDigit())
                }
                .foregroundStyle(Color.faithBrownSoft)

                ProgressView(value: Double(index + 1), total: Double(cardIDs.count))
                    .tint(Color.faithGold)
                    .scaleEffect(y: 0.55)

                ZStack {
                    CardDeckBackdrop()

                    ChoiceCardView(
                        card: card,
                        language: language,
                        selectedOption: selectedOption,
                        onChoose: choose
                    )
                    .id(card.id)
                    .offset(dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset.width / max(proxy.size.width, 1)) * 5))
                    .scaleEffect(cardScale)
                    .opacity(cardOpacity)
                    .simultaneousGesture(dragGesture(width: proxy.size.width))
                }
                .onAppear { cardTravelDistance = max(proxy.size.width * 1.15, 500) }
                .onChange(of: proxy.size.width) { _, width in
                    cardTravelDistance = max(width * 1.15, 500)
                }

                HStack(spacing: 11) {
                    Button(action: previous) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 43, height: 43)
                            .background(Color.faithPaper.opacity(0.90), in: Circle())
                            .overlay { Circle().stroke(Color.faithGold.opacity(0.42), lineWidth: 1) }
                    }
                    .disabled(index == 0 || selectedOption != nil || isTransitioning)

                    Button {
                        contextCard = card
                    } label: {
                        Label(t(.exploreStory), systemImage: "book.closed")
                            .font(.caption.weight(.semibold))
                            .tracking(0.3)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: 220, minHeight: 43)
                            .background(Color.faithGoldLight.opacity(0.52), in: Capsule())
                            .overlay { Capsule().stroke(Color.faithGold.opacity(0.45), lineWidth: 1) }
                    }

                    Button(action: next) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 43, height: 43)
                            .background(Color.faithPaper.opacity(0.90), in: Circle())
                            .overlay { Circle().stroke(Color.faithGold.opacity(0.42), lineWidth: 1) }
                    }
                    .disabled(selectedOption != nil || isTransitioning)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.faithEspresso)
                .shadow(color: Color.faithEspresso.opacity(0.07), radius: 8, y: 4)

                Label(t(.swipeHint), systemImage: "arrow.left.and.right")
                    .font(.caption2)
                    .tracking(0.35)
                    .foregroundStyle(Color.faithBrownSoft.opacity(0.78))
            }
            .frame(maxWidth: min(proxy.size.width, 720), maxHeight: .infinity)
            .padding(.horizontal, 18)
            .padding(.bottom, 14)
            .frame(maxWidth: .infinity)
        }
    }

    private var completionView: some View {
        VStack(spacing: 18) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 62))
                .foregroundStyle(Color.faithGold)
            Text(t(.deckComplete))
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .foregroundStyle(Color.faithEspresso)
            Text(t(.deckCompleteBody))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.faithBrownSoft)
            Button(t(.shuffleAgain)) { shuffle() }
                .buttonStyle(.borderedProminent)
                .tint(Color.faithGold)
                .foregroundStyle(Color.faithPaper)
            Button(t(.anotherDeck)) { dismiss() }
                .foregroundStyle(Color.faithBrown)
        }
        .padding(32)
        .parchmentPanel(cornerRadius: 24)
        .padding(24)
    }

    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 18)
            .onChanged { value in
                guard selectedOption == nil, !isTransitioning else { return }
                dragOffset = CGSize(width: value.translation.width, height: value.translation.height * 0.12)
                let progress = min(abs(value.translation.width) / max(width * 0.75, 1), 1)
                cardOpacity = 1 - (progress * 0.68)
                cardScale = 1 - (progress * 0.018)
            }
            .onEnded { value in
                guard selectedOption == nil, !isTransitioning else { return }
                let threshold = min(width * 0.22, 100)
                if value.translation.width < -threshold {
                    next()
                } else if value.translation.width > threshold {
                    previous()
                } else {
                    withAnimation(.interactiveSpring(response: 0.34, dampingFraction: 0.82)) {
                        dragOffset = .zero
                        cardOpacity = 1
                        cardScale = 1
                    }
                }
            }
    }

    private func choose(_ option: ChoiceOption) {
        guard selectedOption == nil, !isTransitioning, let card = currentCard else { return }
        selectedOption = option
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        let record = ChoiceRecord(
            card: card,
            option: option,
            language: language
        )
        Task { @MainActor in
            do {
                modelContext.insert(record)
                try modelContext.save()
            } catch {
                modelContext.rollback()
                selectedOption = nil
                saveError = error.localizedDescription
                return
            }

            try? await Task.sleep(for: .milliseconds(450))
            selectedOption = nil
            advance(direction: 1)
        }
    }

    private func next() { advance(direction: 1) }
    private func previous() { advance(direction: -1) }

    private func advance(direction: Int) {
        guard !isTransitioning else { return }
        let target = index + direction
        guard target >= 0, target <= cardIDs.count else {
            withAnimation(.interactiveSpring(response: 0.34, dampingFraction: 0.82)) {
                dragOffset = .zero
                cardOpacity = 1
                cardScale = 1
            }
            return
        }
        let outgoing = direction > 0 ? -cardTravelDistance : cardTravelDistance
        if reduceMotion {
            index = target
            dragOffset = .zero
            cardOpacity = 1
            cardScale = 1
        } else {
            isTransitioning = true
            withAnimation(.easeIn(duration: 0.2)) {
                dragOffset.width = outgoing
                cardOpacity = 0
                cardScale = 0.97
            }
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(200))
                index = target
                dragOffset = .zero
                cardScale = 0.975

                guard target < cardIDs.count else {
                    cardOpacity = 1
                    cardScale = 1
                    isTransitioning = false
                    return
                }

                withAnimation(.easeOut(duration: 0.24)) {
                    cardOpacity = 1
                    cardScale = 1
                }
                try? await Task.sleep(for: .milliseconds(240))
                isTransitioning = false
            }
        }
    }

    private func shuffle() {
        cardIDs = persistedCards
            .filter { $0.deckRawValue == deckID.rawValue }
            .map(\.cardID)
            .shuffled()
        index = 0
        selectedOption = nil
        isTransitioning = false
        dragOffset = .zero
        cardOpacity = 1
        cardScale = 1
    }

    private func t(_ key: Strings.Key) -> String { Strings.text(key, language) }
}

private struct CardDeckBackdrop: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.faithIvoryDeep.opacity(0.72))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.faithGold.opacity(0.30), lineWidth: 1)
                }
                .rotationEffect(.degrees(-1.1))
                .scaleEffect(x: 0.97, y: 0.99, anchor: .bottom)
                .offset(y: 10)

            RoundedRectangle(cornerRadius: 18)
                .fill(Color.faithPaper.opacity(0.74))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.faithGold.opacity(0.36), lineWidth: 1)
                }
                .rotationEffect(.degrees(1.35))
                .scaleEffect(x: 0.985, y: 0.995, anchor: .bottom)
                .offset(y: 5)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct ChoiceCardView: View {
    let card: QuestionCard
    let language: AppLanguage
    let selectedOption: ChoiceOption?
    let onChoose: (ChoiceOption) -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                choiceButton(.a, text: card.optionA.value(for: language))

                Rectangle()
                    .fill(Color.faithGold.opacity(0.34))
                    .frame(height: 1)

                choiceButton(.b, text: card.optionB.value(for: language))
            }

            Text(Strings.text(.or, language))
                .font(.system(.caption, design: .serif, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(Color.faithPaper)
                .frame(width: 48, height: 48)
                .background(Color.faithBrown, in: Circle())
                .overlay { Circle().stroke(Color.faithGoldLight, lineWidth: 1) }
                .shadow(color: Color.faithEspresso.opacity(0.20), radius: 9, y: 4)

            OrnamentalCorners()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RadialGradient(
                colors: [.white.opacity(0.92), Color.faithPaper.opacity(0.96)],
                center: .top,
                startRadius: 0,
                endRadius: 330
            ),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.faithGold.opacity(0.56), lineWidth: 1)
        }
        .shadow(color: Color.faithEspresso.opacity(0.18), radius: 24, y: 13)
        .contentShape(RoundedRectangle(cornerRadius: 18))
    }

    private func choiceButton(_ option: ChoiceOption, text: String) -> some View {
        Button { onChoose(option) } label: {
            VStack(spacing: 10) {
                Text(text)
                    .font(.system(.title2, design: .serif, weight: .regular))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.70)
                    .foregroundStyle(Color.faithEspresso)
                    .padding(.horizontal, 26)
                if selectedOption == option {
                    Label(Strings.text(.choiceSaved, language), systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.faithOlive)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .background(selectedOption == option ? Color.faithGoldLight.opacity(0.20) : .clear)
        }
        .buttonStyle(.plain)
        .disabled(selectedOption != nil)
        .accessibilityLabel("\(option.rawValue.uppercased()). \(text)")
        .accessibilityHint(language == .en ? "Double-tap to choose this answer" : "轻点两次选择此答案")
    }
}

struct BiblicalContextView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Query private var persistedDecks: [DeckData]
    @AppStorage(AppLanguage.storageKey) private var languageRawValue = AppLanguage.systemDefault.rawValue
    let card: QuestionCard
    @State private var linkFailed = false
    @State private var copied = false
    @State private var failedReferenceURL: URL?
    private var language: AppLanguage { AppLanguage(rawValue: languageRawValue) ?? .systemDefault }
    private var deck: DeckData? { persistedDecks.first { $0.rawID == card.deckID.rawValue } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(t(.biblicalContext).uppercased())
                        .font(.caption2.weight(.semibold))
                        .tracking(1.5)
                        .foregroundStyle(Color.faithGold)

                    Text(deck?.title(for: language) ?? "")
                        .font(.system(.largeTitle, design: .serif, weight: .regular))
                        .foregroundStyle(Color.faithEspresso)

                    Text(card.context.value(for: language))
                        .font(.body)
                        .foregroundStyle(Color.faithBrown)
                        .lineSpacing(7)

                    PillFlowLayout(spacing: 8) {
                        ForEach(card.scriptureReferences, id: \.englishURL) { reference in
                            Button {
                                openReference(reference)
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "book.closed")
                                        .foregroundStyle(Color.faithGold)
                                    Text(reference.display.value(for: language))
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption2)
                                        .foregroundStyle(Color.faithBrownSoft)
                                }
                                .font(.system(.caption, design: .serif, weight: .medium))
                                .foregroundStyle(Color.faithBrown)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .background(Color.faithGoldLight.opacity(0.14), in: Capsule())
                                .overlay { Capsule().stroke(Color.faithGold.opacity(0.30), lineWidth: 1) }
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint(language == .en
                                               ? "Opens this passage in Bible.com"
                                               : "在 Bible.com 中打开这段经文")
                        }
                    }

                    if copied {
                        Label(t(.copied), systemImage: "checkmark")
                            .font(.caption)
                            .foregroundStyle(Color.faithOlive)
                    }
                }
                .padding(24)
            }
            .background(Color.faithPaper)
            .navigationTitle(t(.biblicalContext))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button(t(.done)) { dismiss() } } }
        }
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(24)
        .alert(t(.linkFailed), isPresented: $linkFailed) {
            Button(t(.retry)) { openReference() }
            Button(t(.copyLink)) {
                if let failedReferenceURL {
                    UIPasteboard.general.url = failedReferenceURL
                    copied = true
                }
            }
            Button(t(.cancel), role: .cancel) {}
        }
    }

    private func openReference(_ reference: BibleReference? = nil) {
        let url = reference?.url(for: language)
            ?? failedReferenceURL
            ?? card.reference.url(for: language)
        openURL(url) { accepted in
            if !accepted {
                failedReferenceURL = url
                linkFailed = true
            }
        }
    }

    private func t(_ key: Strings.Key) -> String { Strings.text(key, language) }
}

private struct LoveSessionPreview: PreviewProvider {
    @MainActor
    static var previews: some View {
        NavigationStack {
            CardSessionView(deckID: .love)
        }
        .modelContainer(for: [
            DeckData.self, CardData.self, DeckTranslationData.self,
            CardTranslationData.self, ChoiceRecord.self, CatalogMetadata.self
        ], inMemory: true)
        .previewDisplayName("Love Session")
    }
}
