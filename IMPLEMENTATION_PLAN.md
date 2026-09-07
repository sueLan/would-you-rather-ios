# Implementation Plan

## Completed release plan

### 1. Project foundation

- [x] Create an iOS 17+ SwiftUI app and unit-test target.
- [x] Configure universal iPhone/iPad support and app identity.
- [x] Establish the navy, ivory, gold, and deck-accent visual system.
- [x] Create original app-icon artwork and the compiled asset catalog.

### 2. Domain model and content

- [x] Define stable deck, card, localized-value, choice-side, and history-record models.
- [x] Build 12 immutable bundled decks.
- [x] Preserve the original 48 prompts and expand every deck to 50 bilingual cards.
- [x] Provide 600 total cards with localized context and references.
- [x] Add locale-specific Bible.com URLs.
- [x] Validate identifiers, localization completeness, per-deck uniqueness, counts, and link structure in tests.

### 3. App state and localization

- [x] Implement shared observable app state.
- [x] Default to the system language and persist an explicit override.
- [x] Localize navigation, controls, empty states, settings, errors, and card content.
- [x] Apply language changes without requiring relaunch.

### 4. Core card experience

- [x] Build the adaptive deck-selection screen.
- [x] Create shuffled, per-deck sessions with stable ordering for the session lifetime.
- [x] Present split A/B parchment cards.
- [x] Add choice highlights, haptics, transition locking, and timed auto-advance.
- [x] Add left/right swipe navigation and equivalent visible controls.
- [x] Add completion and reshuffle states.
- [x] Add a biblical-context sheet with open, retry, and copy-link flows.

### 5. Local history

- [x] Implement an observable atomic Codable store.
- [x] Record localized content snapshots for future-safe history display.
- [x] Show newest-first records grouped by day.
- [x] Add record details, single deletion, and clear-all confirmation.
- [x] Verify persistence and deletion with unit tests.

### 6. Quality and accessibility

- [x] Use scrollable/adaptive layouts for phone and tablet sizes.
- [x] Add semantic accessibility labels and non-gesture alternatives.
- [x] Respect Reduce Motion.
- [x] Handle unavailable networks and malformed local persistence safely.
- [x] Build successfully with Swift 6 strict concurrency settings.
- [x] Run all unit tests on the minimum iOS 17 simulator.
- [x] Install, launch, and visually inspect the app on iOS 17.

## Pre-release checklist

- [ ] Obtain pastoral/editorial review of all prompts and biblical framing.
- [ ] Obtain native-speaker review of Simplified Chinese copy.
- [ ] Test VoiceOver end-to-end on a physical device.
- [ ] Test the release archive on representative physical iPhone and iPad hardware.
- [ ] Confirm the final bundle identifier, signing team, display name, privacy manifest needs, and App Store metadata.
- [ ] Produce App Store screenshots and complete TestFlight acceptance testing.
