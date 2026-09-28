# Localization workflow

The app defines 13 languages. English and Simplified Chinese are currently
reviewed and available. New languages remain hidden until their complete
catalog bundle passes validation and receives human approval.

## Planned languages

Spanish (`es`), Portuguese (`pt`), French (`fr`), German (`de`), Hindi (`hi`),
Arabic (`ar`), Bengali (`bn`), Indonesian (`id`), Japanese (`ja`), Korean
(`ko`), and Thai (`th`).

## Reviewer bundle

`CatalogTranslationBundle.reviewTemplate(for:payload:)` produces the complete
English source template for one language. A reviewer translates every deck and
card value, verifies the Bible reference URL and localized book name, and then
changes the review metadata from `draft` to `reviewed`, adding their name and
review date.

A valid bundle must:

- use the current schema version;
- contain each of the 12 deck IDs exactly once;
- contain each of the 600 card IDs exactly once;
- contain no empty title, summary, choice, context, or reference text;
- use stable BCP-47 language codes;
- be marked reviewed only by an authorized fluent reviewer.

Arabic also requires a complete right-to-left UI review. Reviewers should test
long text, Dynamic Type, VoiceOver pronunciation, line wrapping, card gestures,
and locally appropriate Bible-book and translation names.

Do not add a language to `TranslationRegistry.reviewedLanguages` until its
bundle has passed automated validation and human review.

Approved JSON bundles belong in `WouldYouRather/Localizations`. The app loads
that directory at startup, validates every bundle, and imports its deck and
card translations into normalized SwiftData rows. Add the language to
`reviewedLanguages` and increment `CatalogSeeder.cardVersion` in the same
release so existing installations reseed their card catalog.

## Apple on-device translation

On iOS 18 and later, languages supported by Apple's Translation framework can
be selected before a reviewed bundle is available. The app translates the 12
deck descriptions as a small batch, then translates only the selected deck's
missing card content. Results are cached in the same normalized SwiftData rows.

Apple translation is machine-generated and is labeled in the card experience.
The original curated Bible URLs are never translated. General interface text
falls back to English until it receives a bundled localization. iOS 17 keeps
the bundled English and Simplified Chinese experience because the Translation
framework is unavailable there. Translation support and model installation
must be tested on a physical device; the framework does not translate in the
iOS Simulator.
