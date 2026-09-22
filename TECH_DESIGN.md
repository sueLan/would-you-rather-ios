# Would You Rather: Faith — Technical Design

## 1. Product scope

The app is an offline-first, bilingual Christian conversation-card experience for iPhone and iPad. A player selects one of 12 decks, chooses between option A and option B, optionally reads the biblical context, and can revisit prior choices in History.

The first release includes:

- Love, Faith, Connection, Reflection, Wisdom, Prayer, Purpose, Courage, Gratitude, Forgiveness, Service, and Hope decks
- 50 cards per deck (600 total)
- English and Simplified Chinese content and interface text
- Swipe and button navigation
- Local choice history
- Direct Bible.com passage links
- Reduced-motion and VoiceOver-friendly interactions

Accounts, syncing, multiplayer, content downloads, notifications, and analytics are outside this release.

## 2. Platform and dependencies

- Deployment target: iOS/iPadOS 17.0+
- UI: SwiftUI
- Language: Swift 6
- State observation: Combine `ObservableObject`
- Persistence: Foundation `Codable` JSON
- External packages: none

Using Apple frameworks only keeps startup deterministic and allows the complete card experience to work offline. `ObservableObject` and a Codable store are used instead of newer generated runtime features so the binary remains compatible with the iOS 17 deployment target when built by the current Xcode toolchain.

## 3. Architecture

The app uses a small unidirectional composition:

```text
WouldYouRatherApp
  ├─ AppState (language, immutable catalog)
  ├─ ChoiceHistoryStore (persistent choice records)
  └─ RootView
       ├─ DeckListView → CardSessionView → ContextSheet
       └─ SettingsView → HistoryView → HistoryDetailView
```

### AppState

`AppState` is the app-wide source of truth for the selected language. It exposes localized catalog lookups and persists the explicit language setting in `UserDefaults`. Language changes are immediately reflected because all screens observe the same object.

### ContentCatalog

`ContentCatalog` is immutable bundled content. Decks and cards have stable identifiers, while user-visible strings are represented by paired English and Chinese values. The original 48 hand-authored prompts keep their existing identifiers. `CatalogExpansion` fills every deck to 50 cards by combining 10 deck-specific subjects with five complementary decision lenses: visible action or prayer, action or counsel, community or private practice, costly or sustainable response, and words or deeds. Keeping content typed in Swift makes missing fields, repeated choice pairs, and invalid deck relationships visible during development and test execution.

Each card contains:

- stable identifier and deck identifier
- localized A and B choices
- localized discussion context
- one card-specific Bible reference plus three deck-relevant companion passages
- localized reference labels and English/Chinese Bible.com URLs

The app links to translations but does not redistribute Scripture text.

### CardSessionView

A session creates a shuffled array of stable card identifiers and owns only ephemeral presentation state: current index, selected side, swipe offset, context-sheet state, and transition lock.

The interaction sequence is:

1. User taps A/B or swipes to navigate.
2. A choice tap gives haptic feedback and records a snapshot in history.
3. The selected half is highlighted.
4. After 450 ms the active card moves in the navigation direction while fading away.
5. The replacement card fades in at the deck origin above two subtle backing cards.
6. Reduce Motion replaces the sequence with an immediate state change, and a transition guard prevents duplicate writes from rapid taps.

Swipe left advances; swipe right returns to the previous card. Visible buttons provide equivalent controls and improve discoverability and accessibility.

### ChoiceHistoryStore

The history store publishes a newest-first array of `ChoiceRecord` values. Each record contains a UUID, timestamp, deck, card identifier, chosen side, and bilingual snapshots of both options and the biblical context.

Snapshotting protects historical readability if bundled prompts change in a later app version. Mutations are persisted using atomic JSON replacement with complete file protection. A malformed file fails safely to an empty history rather than blocking launch.

The observable store is isolated to the main actor. A separate storage actor performs file access and JSON processing off the main actor. Its synchronous isolated methods do not suspend during a read or write. Async mutations wait for initial loading and preceding mutations, and publish records only after persistence succeeds; failed saves leave the published state unchanged.

Supported operations are append, delete one record, and clear all records. History remains on-device and is never transmitted.

## 4. Navigation and screen design

`RootView` presents the deck grid in a single navigation stack, without a bottom tab bar. A top-right gear opens Settings. Settings contains the History entry along with language, privacy, and app information; History shows records grouped by calendar day with detail and deletion.

The visual system mirrors the companion website: warm ivory-to-parchment gradients, espresso text, antique-gold rules, subtle olive mountain silhouettes, luminous paper surfaces, and fine ornamental corners. Serif display type gives the experience an editorial, Bible-inspired tone while system body type preserves legibility. The card screen uses a centered espresso “OR” seal, layered paper deck, circular arrow controls, and a gold story pill. Layouts use adaptive grids and scroll containers to support iPhone and iPad sizes and large content.

## 5. Localization

The initial language is derived from the system locale unless the user previously selected one. UI labels live in `Strings`, while deck and card content use localized value pairs. URLs select NIV for English and CUNPSS for Chinese.

This structure supports adding another language by extending the language enum and supplying values at the two localization boundaries, without changing session or persistence logic.

## 6. Accessibility and resilience

- Interactive controls use semantic labels and system symbols.
- A/B choices are exposed as buttons, not gesture-only regions.
- Dynamic Type-compatible font styles are used throughout.
- Reduce Motion replaces major motion with simpler state changes.
- External URL failures show retry and copy-link actions.
- The app remains fully usable without a network connection except for opening Bible.com.
- Choice writes are guarded against rapid duplicate input.

## 7. Testing strategy

Unit tests verify:

- more than 10 decks, exactly 50 cards per deck, and 600 cards total
- unique choice pairs within each deck
- unique card identifiers and complete bilingual values
- HTTPS Bible links and expected translation identifiers
- history persistence, reload, and deletion

Release verification also includes a generic simulator build and an actual launch smoke test on the minimum supported iOS 17 runtime. Manual acceptance should cover both languages, every deck, swipe directions, context links, History deletion, relaunch persistence, VoiceOver, Reduce Motion, and representative iPhone/iPad layouts.

## 8. Future evolution

If the product later needs downloadable content or cloud sync, place a repository boundary in front of `ContentCatalog` and `ChoiceHistoryStore`. The current stable IDs and Codable records already provide migration anchors. Schema versioning should be added before the first persistent format change.
