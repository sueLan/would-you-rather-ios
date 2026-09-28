import SwiftUI
@preconcurrency import Translation

struct SettingsView: View {
    @AppStorage(AppLanguage.storageKey) private var languageRawValue = AppLanguage.systemDefault.rawValue
    @State private var dynamicallySupportedLanguages: Set<AppLanguage> = []
    private var language: AppLanguage { AppLanguage(rawValue: languageRawValue) ?? .systemDefault }

    var body: some View {
        ZStack {
            FaithBackdrop()

            Form {
                Section {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Label(t(.history), systemImage: "clock.arrow.circlepath")
                            .foregroundStyle(Color.faithEspresso)
                    }
                }

                Section(t(.language)) {
                    Menu {
                        ForEach(AppLanguage.allCases) { candidate in
                            let isAvailable = isAvailable(candidate)
                            Button {
                                languageRawValue = candidate.rawValue
                            } label: {
                                if candidate == language {
                                    Label(candidate.displayName, systemImage: "checkmark")
                                } else if isAvailable {
                                    Text(candidate.displayName)
                                } else {
                                    Text("\(candidate.displayName) — \(t(.translationPending))")
                                }
                            }
                            .disabled(!isAvailable)
                        }
                    } label: {
                        HStack {
                            Text(t(.language))
                                .foregroundStyle(Color.faithEspresso)
                            Spacer()
                            Text(language.displayName)
                                .foregroundStyle(Color.faithBrownSoft)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.faithGold)
                        }
                    }
                    .accessibilityValue("\(language.displayName), \(t(.selected))")
                }

                Section(t(.about)) {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Would You Rather: Faith")
                                .font(.system(.headline, design: .serif, weight: .semibold))
                                .foregroundStyle(Color.faithEspresso)
                            Text(t(.appDescription))
                                .font(.subheadline)
                                .foregroundStyle(Color.faithBrownSoft)
                        }
                    } icon: {
                        Image(systemName: "book.pages.fill")
                            .foregroundStyle(Color.faithGold)
                    }
                    LabeledContent(t(.version), value: "1.0")
                }

                Section(t(.privacy)) {
                    Text(t(.privacyBody))
                        .font(.subheadline)
                        .foregroundStyle(Color.faithBrownSoft)
                }

                Section {
                    Text(language == .en
                         ? "Bible references open Bible.com. Scripture text is not reproduced in this app."
                         : "圣经经文链接会打开 Bible.com。本应用不复制圣经译文正文。")
                        .font(.caption)
                        .foregroundStyle(Color.faithBrownSoft)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(t(.settings))
        .toolbarBackground(Color.faithPaper.opacity(0.88), for: .navigationBar)
        .task { await loadDynamicLanguageSupport() }
    }

    private func t(_ key: Strings.Key) -> String { Strings.text(key, language) }

    private func isAvailable(_ candidate: AppLanguage) -> Bool {
        TranslationRegistry.isAvailable(candidate)
            || dynamicallySupportedLanguages.contains(candidate)
    }

    private func loadDynamicLanguageSupport() async {
        guard #available(iOS 18.0, *) else { return }
        let availability = LanguageAvailability()
        var supported: Set<AppLanguage> = []
        for candidate in TranslationRegistry.awaitingReview {
            let status = await availability.status(
                from: AppLanguage.en.localeLanguage,
                to: candidate.localeLanguage
            )
            if status != .unsupported {
                supported.insert(candidate)
            }
        }
        dynamicallySupportedLanguages = supported
    }
}
