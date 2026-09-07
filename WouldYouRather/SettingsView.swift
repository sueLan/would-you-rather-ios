import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

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
                    Picker(t(.language), selection: $appState.language) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
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
                    Text(appState.language == .en
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
    }

    private func t(_ key: Strings.Key) -> String { Strings.text(key, appState.language) }
}
