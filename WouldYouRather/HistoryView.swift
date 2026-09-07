import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var historyStore: ChoiceHistoryStore
    @State private var showClearConfirmation = false

    private var records: [ChoiceRecord] { historyStore.records }
    private var groupedRecords: [(day: Date, records: [ChoiceRecord])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: records) { calendar.startOfDay(for: $0.chosenAt) }
        return groups.keys.sorted(by: >).map { ($0, groups[$0] ?? []) }
    }

    var body: some View {
        ZStack {
            FaithBackdrop()

            Group {
                if records.isEmpty {
                    ContentUnavailableView(
                        t(.noHistory),
                        systemImage: "clock.badge.questionmark",
                        description: Text(t(.noHistoryBody))
                    )
                    .foregroundStyle(Color.faithBrown)
                } else {
                    List {
                        ForEach(groupedRecords, id: \.day) { group in
                            Section(group.day.formatted(date: .abbreviated, time: .omitted)) {
                                ForEach(group.records) { record in
                                    NavigationLink {
                                        HistoryDetailView(record: record)
                                    } label: {
                                        HistoryRow(record: record)
                                    }
                                }
                                .onDelete { offsets in
                                    for index in offsets {
                                        try? historyStore.delete(id: group.records[index].id)
                                    }
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.insetGrouped)
                }
            }
        }
        .navigationTitle(t(.history))
        .toolbarBackground(Color.faithPaper.opacity(0.88), for: .navigationBar)
        .toolbar {
            if !records.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(t(.clearAll), role: .destructive) { showClearConfirmation = true }
                }
            }
        }
        .confirmationDialog(t(.clearConfirm), isPresented: $showClearConfirmation, titleVisibility: .visible) {
            Button(t(.clearAll), role: .destructive) { clearAll() }
            Button(t(.cancel), role: .cancel) {}
        }
    }

    private func clearAll() {
        try? historyStore.deleteAll()
    }

    private func t(_ key: Strings.Key) -> String { Strings.text(key, appState.language) }
}

private struct HistoryRow: View {
    let record: ChoiceRecord

    private var deck: DeckID? { DeckID(rawValue: record.deckID) }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: deck?.symbol ?? "rectangle.stack")
                .foregroundStyle(Color.faithGold)
                .frame(width: 38, height: 38)
                .background(Color.faithGoldLight.opacity(0.18), in: Circle())
                .overlay { Circle().stroke(Color.faithGold.opacity(0.24), lineWidth: 1) }

            VStack(alignment: .leading, spacing: 5) {
                Text(record.answerSnapshot)
                    .font(.system(.headline, design: .serif, weight: .regular))
                    .foregroundStyle(Color.faithEspresso)
                    .lineLimit(2)
                HStack {
                    Text(record.selectedOption.uppercased())
                        .font(.caption2.weight(.black))
                        .foregroundStyle(Color.faithGold)
                    Text(record.chosenAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(Color.faithBrownSoft)
                }
            }
        }
        .padding(.vertical, 5)
        .accessibilityElement(children: .combine)
    }
}

private struct HistoryDetailView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.openURL) private var openURL
    let record: ChoiceRecord

    var body: some View {
        ZStack {
            FaithBackdrop()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text(record.questionSnapshot)
                        .font(.system(.title2, design: .serif, weight: .regular))
                        .foregroundStyle(Color.faithEspresso)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(t(.yourChoice).uppercased())
                            .font(.caption2.weight(.semibold))
                            .tracking(1.2)
                            .foregroundStyle(Color.faithGold)
                        HStack(alignment: .top, spacing: 12) {
                            Text(record.selectedOption.uppercased())
                                .font(.caption.weight(.black))
                                .foregroundStyle(Color.faithPaper)
                                .frame(width: 30, height: 30)
                                .background(Color.faithBrown, in: Circle())
                            Text(record.answerSnapshot)
                                .font(.system(.headline, design: .serif, weight: .regular))
                                .foregroundStyle(Color.faithEspresso)
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .parchmentPanel(cornerRadius: 18)

                    Divider().overlay(Color.faithGold.opacity(0.35))

                    Label(t(.biblicalContext), systemImage: "book.closed")
                        .font(.headline)
                        .foregroundStyle(Color.faithGold)
                    Text(record.contextSnapshot)
                        .font(.body)
                        .foregroundStyle(Color.faithBrown)
                        .lineSpacing(5)
                    Text(record.referenceDisplay)
                        .font(.system(.subheadline, design: .serif, weight: .semibold))
                        .foregroundStyle(Color.faithBrownSoft)

                    if let url = URL(string: record.referenceURL) {
                        Button {
                            openURL(url)
                        } label: {
                            Label(t(.openInBible), systemImage: "arrow.up.forward.app.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.faithBrown)
                    }

                    Text(record.chosenAt.formatted(date: .long, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(Color.faithBrownSoft)
                }
                .padding(22)
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(t(.history))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func t(_ key: Strings.Key) -> String { Strings.text(key, appState.language) }
}
