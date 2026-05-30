# VerseFlip

VerseFlip is a SwiftUI iOS app for saving Bible verses as flashcards and reviewing them for memorization. The app supports browsing local KJV verse data, creating verse cards, organizing cards into decks, and reviewing saved cards with simple progress states.

## Features

- Onboarding flow with splash and nickname screens.
- Home dashboard with today's verse and progress surfaces.
- Verse picker flow for Bible version, book, chapter, verse selection, and card preview.
- Local KJV browsing from bundled JSON data.
- ESV and NIV version options are present but intentionally unavailable until official licensed integrations are implemented.
- Flashcard library with decks, saved verse rows, deck detail views, and deck creation.
- Review flow with flip cards and Again, Good, and Memorized outcomes.
- Local JSON persistence for decks and verse cards in Application Support.
- Shared SwiftUI theme, cards, buttons, search, status chip, and spacing components.

## Project Structure

```text
VerseFlip/
├── UIMockups/                         # Original UI reference images
├── VerseFlip/
│   ├── Assets.xcassets/               # App icon and colors
│   ├── Components/                    # Shared SwiftUI UI components
│   ├── Data/kjv.json                  # Bundled local KJV verse data
│   ├── Models/                        # Bible, deck, card, and review models
│   ├── Services/                      # Bible data service abstractions
│   ├── Storage/                       # Local JSON stores
│   ├── Theme/                         # Color, font, and spacing tokens
│   ├── ViewModels/                    # Screen state and app logic
│   ├── Views/                         # SwiftUI screens by feature
│   ├── ContentView.swift              # Onboarding/main-tab routing
│   └── VerseFlipApp.swift             # App entry point
├── VerseFlip.xcodeproj
└── verseflip-codex-implementation-phases.md
```

## Requirements

- macOS with Xcode installed.
- iOS 16.6 or newer deployment target.
- SwiftUI.

The project is an Xcode app project, not a Swift Package. Open `VerseFlip.xcodeproj` in Xcode to build and run it on a simulator or device.

## Getting Started

1. Open the project:

   ```bash
   open VerseFlip.xcodeproj
   ```

2. Select the `VerseFlip` scheme.
3. Choose an iOS simulator or connected device.
4. Build and run from Xcode.

## Bible Data and Licensing Notes

KJV is loaded locally from `VerseFlip/Data/kjv.json`.

ESV and NIV are modeled in the app, but their services currently return unavailable states. Do not bundle copyrighted ESV or NIV text directly in this repository. Future support should use official, licensed API access or another properly licensed source.

Optional API key lookup already exists for these Info.plist keys:

```text
ESV_API_KEY
NIV_API_KEY
```

Providing those keys does not enable ESV or NIV yet; the official integrations still need to be implemented.

## Local Persistence

The app writes user-created data as JSON files under the user's Application Support directory:

```text
Application Support/VerseFlip/decks.json
Application Support/VerseFlip/verse_cards.json
```

`DeckStore` ensures a default deck exists, and `VerseCardStore` stores saved flashcards with review status and review timestamps.

## Development Notes

- Keep changes scoped to the existing feature directories.
- Use the shared `Theme/` and `Components/` helpers before introducing new one-off styling.
- Use the mockups in `UIMockups/` as the root visual reference set.
- Keep KJV functional locally when changing Bible service code.
- Treat ESV and NIV as unavailable until official licensed integrations are added.

## Useful Verification Commands

When full Xcode builds are available, prefer building and testing through Xcode.

In a command-line-only environment, these checks are useful fallbacks:

```bash
plutil -lint VerseFlip.xcodeproj/project.pbxproj
swiftc -parse $(rg --files VerseFlip -g '*.swift')
swiftc -typecheck $(rg --files VerseFlip/Models VerseFlip/Services VerseFlip/Storage VerseFlip/ViewModels -g '*.swift')
git diff --check
```

These fallback checks do not replace a real iOS simulator build, but they catch many syntax, project-file, and whitespace issues.
