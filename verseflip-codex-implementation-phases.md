# VerseFlip iOS App — Refactored Codex Implementation Phases

This Markdown file is refactored to match the **current actual project directory** shown in your Finder screenshot.

Codex should use this file as the main implementation guide and must implement the app **phase by phase**.

---

# 0. Current Project Directory

Your current project appears to be structured like this:

```text
VerseFlip/
│
├── UIMockups/
│   ├── 01-splash-screen.png
│   ├── 02-home-screen.png
│   ├── 03-add-verse-bible-version-screen.png
│   ├── 04-book-selection-screen.png
│   ├── 05-chapter-selection-screen.png
│   ├── 06-verse-selection-screen.png
│   ├── 07-preview-card-screen.png
│   ├── 08-library-screen.png
│   ├── 09-review-flashcard-screen.png
│   └── 10-review-complete-screen.png
│
├── VerseFlip/
│   ├── Assets.xcassets/
│   ├── Components/
│   ├── ContentView.swift
│   ├── Theme/
│   └── VerseFlipApp.swift
│
├── verseflip-codex-implementation-phases.md
└── VerseFlip.xcodeproj
```

## Important Path Rule

The UI mockups are located at the project root:

```text
./UIMockups/
```

Do **not** look for mockups inside:

```text
./VerseFlip/DesignReferences/UI-Mockups/
```

That folder does not match the current project directory.

---

# 1. UI Reference Files

Codex must use these exact UI mockup paths as visual references:

```text
./UIMockups/01-splash-screen.png
./UIMockups/02-home-screen.png
./UIMockups/03-add-verse-bible-version-screen.png
./UIMockups/04-book-selection-screen.png
./UIMockups/05-chapter-selection-screen.png
./UIMockups/06-verse-selection-screen.png
./UIMockups/07-preview-card-screen.png
./UIMockups/08-library-screen.png
./UIMockups/09-review-flashcard-screen.png
./UIMockups/10-review-complete-screen.png
```

---

# 2. App Summary

## App Name

```text
VerseFlip
```

## App Purpose

VerseFlip is an iOS Bible verse memorization app that allows users to:

```text
Browse Bible verses
Select one or more verses
Save selected verses as flashcards
Review saved verses using flip cards
Track learning and memorization progress
```

## Main User Flow

```text
Open App
  ↓
Splash Screen
  ↓
Home
  ↓
Add Verse
  ↓
Choose Bible Version
  ↓
Select Book
  ↓
Select Chapter
  ↓
Select Verse
  ↓
Preview Card
  ↓
Save Card
  ↓
Library
  ↓
Review Flashcard
  ↓
Mark Again / Good / Memorized
```

---

# 3. Codex Rules

Codex must follow these rules for every phase:

```text
1. Implement only the requested phase.
2. Do not implement future phases unless explicitly asked.
3. Do not delete existing files unless required and explained.
4. Do not rewrite the whole project.
5. Preserve existing working code.
6. Use the actual current directory structure.
7. Use UI references from ./UIMockups/.
8. Keep the app buildable after every phase.
9. Prefer small, readable SwiftUI components.
10. Summarize changed files after each phase.
```

---

# 4. Final Target Project Structure

Codex should gradually evolve the app into this structure:

```text
VerseFlip/
│
├── UIMockups/
│   ├── 01-splash-screen.png
│   ├── 02-home-screen.png
│   ├── 03-add-verse-bible-version-screen.png
│   ├── 04-book-selection-screen.png
│   ├── 05-chapter-selection-screen.png
│   ├── 06-verse-selection-screen.png
│   ├── 07-preview-card-screen.png
│   ├── 08-library-screen.png
│   ├── 09-review-flashcard-screen.png
│   └── 10-review-complete-screen.png
│
├── VerseFlip/
│   ├── Assets.xcassets/
│   │
│   ├── Components/
│   │   ├── VFBackButton.swift
│   │   ├── VFCard.swift
│   │   ├── VFIconCircle.swift
│   │   ├── VFPrimaryButton.swift
│   │   ├── VFSearchBar.swift
│   │   ├── VFSecondaryButton.swift
│   │   ├── VFSectionHeader.swift
│   │   └── VFStatusChip.swift
│   │
│   ├── Data/
│   │   └── kjv_sample_bible.json
│   │
│   ├── Models/
│   │   ├── BibleBook.swift
│   │   ├── BibleChapter.swift
│   │   ├── BibleVerse.swift
│   │   ├── BibleVersion.swift
│   │   ├── Deck.swift
│   │   ├── ReviewStatus.swift
│   │   └── VerseCard.swift
│   │
│   ├── Services/
│   │   ├── BibleServiceProtocol.swift
│   │   ├── BibleServiceFactory.swift
│   │   ├── LocalBibleService.swift
│   │   ├── ESVBibleAPIService.swift
│   │   └── NIVBibleAPIService.swift
│   │
│   ├── Storage/
│   │   ├── DeckStore.swift
│   │   └── VerseCardStore.swift
│   │
│   ├── Theme/
│   │   ├── VFColors.swift
│   │   ├── VFFonts.swift
│   │   └── VFSpacing.swift
│   │
│   ├── ViewModels/
│   │   ├── AddVerseViewModel.swift
│   │   ├── HomeViewModel.swift
│   │   ├── LibraryViewModel.swift
│   │   └── ReviewViewModel.swift
│   │
│   ├── Views/
│   │   ├── Splash/
│   │   │   └── SplashView.swift
│   │   │
│   │   ├── Home/
│   │   │   ├── HomeView.swift
│   │   │   ├── ProgressCardView.swift
│   │   │   └── TodayVerseCardView.swift
│   │   │
│   │   ├── AddVerse/
│   │   │   ├── BibleVersionSelectionView.swift
│   │   │   ├── BookSelectionView.swift
│   │   │   ├── ChapterSelectionView.swift
│   │   │   ├── VerseSelectionView.swift
│   │   │   └── VersePreviewView.swift
│   │   │
│   │   ├── Library/
│   │   │   ├── LibraryView.swift
│   │   │   ├── DeckCardView.swift
│   │   │   ├── DeckDetailView.swift
│   │   │   ├── SavedVerseRowView.swift
│   │   │   └── CreateDeckView.swift
│   │   │
│   │   ├── Review/
│   │   │   ├── ReviewView.swift
│   │   │   ├── FlipCardView.swift
│   │   │   └── ReviewCompleteView.swift
│   │   │
│   │   └── Profile/
│   │       └── ProfileView.swift
│   │
│   ├── ContentView.swift
│   └── VerseFlipApp.swift
│
├── verseflip-codex-phases-refactored.md
└── VerseFlip.xcodeproj
```

---

# 5. Design System

## Color Palette

Codex should use this color palette throughout the app:

```text
Primary Navy: #17223B
Warm Cream: #F8F4EC
Soft Gold: #D6A84F
Text Dark: #1F2937
Text Muted: #6B7280
Card Background: #FFFFFF
Soft Border: #E7E1D6
Success Green: #DDEAD8
Learning Blue: #E8EEF8
Danger Red: #C75C48
```

## UI Style

The app should look like the mockups:

```text
Soft cream background
Deep navy text
Soft gold accent icons
White rounded cards
Subtle shadows
Large readable typography
Minimal Christian/Bible-inspired visual language
Simple iOS-style navigation
```

---

# Phase 0 — Verify Current Project and Prepare Structure

## Goal

Make sure the current project structure is ready for feature implementation.

## Codex Prompt

```text
Read verseflip-codex-phases-refactored.md and implement Phase 0 only.

Verify the current VerseFlip project structure. The UI mockups are in ./UIMockups/. The app source code is in ./VerseFlip/. Keep the existing Components and Theme folders. Create missing folders only if they do not exist: Models, Services, Storage, ViewModels, Views, Data. Do not move the UIMockups folder. Keep the app buildable.
```

## Tasks

- Confirm the following exist:

```text
./UIMockups/
./VerseFlip/
./VerseFlip/Components/
./VerseFlip/Theme/
./VerseFlip/ContentView.swift
./VerseFlip/VerseFlipApp.swift
./VerseFlip.xcodeproj
```

- Create missing folders:

```text
./VerseFlip/Models/
./VerseFlip/Services/
./VerseFlip/Storage/
./VerseFlip/ViewModels/
./VerseFlip/Views/
./VerseFlip/Data/
```

- Inside `Views`, create subfolders if they do not exist:

```text
Splash
Home
AddVerse
Library
Review
Profile
```

## Done When

```text
The app still builds.
The project structure is organized.
The UIMockups folder remains at the root.
No feature logic has been added yet.
```

---

# Phase 1 — Theme and Reusable Components

## Goal

Create the design system and reusable UI components based on the mockups.

## Codex Prompt

```text
Read verseflip-codex-phases-refactored.md and implement Phase 1 only.

Create or update the VerseFlip theme and reusable components inside ./VerseFlip/Theme/ and ./VerseFlip/Components/. Use the colors and style described in the MD and match the UI references in ./UIMockups/. Do not build full screens yet.
```

## Files to Create or Update

```text
./VerseFlip/Theme/VFColors.swift
./VerseFlip/Theme/VFFonts.swift
./VerseFlip/Theme/VFSpacing.swift

./VerseFlip/Components/VFPrimaryButton.swift
./VerseFlip/Components/VFSecondaryButton.swift
./VerseFlip/Components/VFCard.swift
./VerseFlip/Components/VFIconCircle.swift
./VerseFlip/Components/VFSectionHeader.swift
./VerseFlip/Components/VFStatusChip.swift
./VerseFlip/Components/VFSearchBar.swift
./VerseFlip/Components/VFBackButton.swift
```

## Component Requirements

### VFPrimaryButton

Used for:

```text
Get Started
Start Review
Continue
Add Selected Verse
Save Card
Review Again
```

### VFSecondaryButton

Used for:

```text
View Library
Back to Home
Outlined actions
```

### VFCard

Used for:

```text
Home progress cards
Verse of the day card
Deck cards
Flashcards
Preview cards
```

### VFStatusChip

Statuses:

```text
Learning
Reviewing
Memorized
Difficult
```

## Done When

```text
Theme files compile.
Reusable components compile.
Colors are centralized.
Components visually match the mockup style.
No full page implementation yet.
```

---

# Phase 2 — Models and Local Storage

## Goal

Create the core data models and simple local persistence.

## Codex Prompt

```text
Read verseflip-codex-phases-refactored.md and implement Phase 2 only.

Create the core models and local storage classes for VerseFlip. Use simple Codable JSON storage for the MVP unless SwiftData is already configured. Keep the app buildable and do not implement UI screens in this phase.
```

## Files to Create

```text
./VerseFlip/Models/VerseCard.swift
./VerseFlip/Models/Deck.swift
./VerseFlip/Models/BibleVersion.swift
./VerseFlip/Models/BibleBook.swift
./VerseFlip/Models/BibleChapter.swift
./VerseFlip/Models/BibleVerse.swift
./VerseFlip/Models/ReviewStatus.swift

./VerseFlip/Storage/VerseCardStore.swift
./VerseFlip/Storage/DeckStore.swift
```

## Suggested Models

```swift
struct VerseCard: Identifiable, Codable, Hashable {
    let id: UUID
    var verseText: String
    var reference: String
    var book: String
    var chapter: Int
    var verseStart: Int
    var verseEnd: Int?
    var bibleVersion: BibleVersion
    var deckId: UUID
    var reviewStatus: ReviewStatus
    var dateAdded: Date
    var lastReviewedAt: Date?
}
```

```swift
struct Deck: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var iconName: String
    var createdAt: Date
}
```

```swift
enum ReviewStatus: String, Codable, CaseIterable {
    case learning
    case reviewing
    case memorized
    case difficult
}
```

```swift
enum BibleVersion: String, Codable, CaseIterable, Identifiable {
    case kjv = "KJV"
    case esv = "ESV"
    case niv = "NIV"

    var id: String { rawValue }
}
```

## Done When

```text
Models compile.
Deck storage can save and load decks.
Verse card storage can save and load cards.
A default deck can be created.
No UI has been implemented yet.
```

---

# Phase 3 — Navigation Shell

## Goal

Create the main app navigation and placeholder screens.

## Codex Prompt

```text
Read verseflip-codex-phases-refactored.md and implement Phase 3 only.

Create the navigation shell for VerseFlip. Add SplashView, MainTabView, and placeholder pages for Home, Library, Review, and Profile. Add placeholder routes for the Add Verse flow. Use the actual app source path ./VerseFlip/. Keep the app buildable.
```

## Files to Create

```text
./VerseFlip/Views/Splash/SplashView.swift
./VerseFlip/Views/MainTabView.swift
./VerseFlip/Views/Home/HomeView.swift
./VerseFlip/Views/AddVerse/BibleVersionSelectionView.swift
./VerseFlip/Views/AddVerse/BookSelectionView.swift
./VerseFlip/Views/AddVerse/ChapterSelectionView.swift
./VerseFlip/Views/AddVerse/VerseSelectionView.swift
./VerseFlip/Views/AddVerse/VersePreviewView.swift
./VerseFlip/Views/Library/LibraryView.swift
./VerseFlip/Views/Review/ReviewView.swift
./VerseFlip/Views/Profile/ProfileView.swift
```

## Update

```text
./VerseFlip/ContentView.swift
```

## Navigation Requirements

```text
App launches to SplashView.
Get Started opens MainTabView.
MainTabView contains Home, Library, Review, and Profile.
Add Verse flow can be reached from Home.
```

## Done When

```text
App launches successfully.
Splash placeholder appears.
Main tab navigation works.
All placeholder views compile.
```

---

# Phase 4 — Splash Screen and Home Screen

## Goal

Implement the splash and home screens using the actual mockup files.

## Codex Prompt

```text
Read verseflip-codex-phases-refactored.md and implement Phase 4 only.

Build the SplashView and HomeView to match these references:
./UIMockups/01-splash-screen.png
./UIMockups/02-home-screen.png

Use the existing Theme and Components. Use static sample data for now. Keep the app buildable.
```

## Reference Images

```text
./UIMockups/01-splash-screen.png
./UIMockups/02-home-screen.png
```

## Splash Screen Content

```text
VerseFlip logo/icon
VerseFlip app name
Memorize Scripture, one card at a time.
Flip. Review. Remember.
Get Started button
```

## Home Screen Content

```text
Good morning, JD
Ready to review Scripture today?
Today's Review card
5 cards due
Start Review button
Today's Progress card
12 verses saved
5 due for review
3 memorized
Verse of the Day card
John 3:16 NIV
Quick Actions
Add Verse button
View Library button
```

## Files to Update or Create

```text
./VerseFlip/Views/Splash/SplashView.swift
./VerseFlip/Views/Home/HomeView.swift
./VerseFlip/Views/Home/ProgressCardView.swift
./VerseFlip/Views/Home/TodayVerseCardView.swift
```

## Done When

```text
Splash screen visually follows 01-splash-screen.png.
Home screen visually follows 02-home-screen.png.
Get Started works.
Add Verse button navigates to Add Verse flow.
View Library opens the Library tab.
```

---

# Phase 5 — Local KJV Bible Data Service

## Goal

Add local full KJV JSON data and a Bible service for browsing Scripture.

The app should use the downloaded full KJV file:

```text
./VerseFlip/Data/kjv.json
```

Do **not** create a sample Bible JSON file unless `kjv.json` is missing.

## Codex Prompt

```text
Read verseflip-codex-phases-refactored.md and implement Phase 5 only.

Add a local KJV Bible data service using the existing full KJV JSON file located at ./VerseFlip/Data/kjv.json.

Do not create kjv_sample_bible.json unless kjv.json is missing.

The JSON format is:
- root object contains metadata
- root object contains verses
- verses is an array
- each verse has book_name, book, chapter, verse, and text

Build LocalBibleService to decode this exact format and group verses by book_name, chapter, and verse.

The service should allow the app to browse books, chapters, verses, and verse ranges from the local KJV JSON file.

Do not use APIs yet.
```

## Existing File Required

```text
./VerseFlip/Data/kjv.json
```

## Files to Create

```text
./VerseFlip/Services/BibleServiceProtocol.swift
./VerseFlip/Services/LocalBibleService.swift
```

## Files to Check or Update

```text
./VerseFlip/Models/BibleBook.swift
./VerseFlip/Models/BibleChapter.swift
./VerseFlip/Models/BibleVerse.swift
./VerseFlip/Models/BibleVersion.swift
```

## KJV JSON Structure

The `kjv.json` file should be decoded using this general structure:

```json
{
  "metadata": {
    "name": "Authorized King James Version",
    "shortname": "KJV",
    "module": "kjv"
  },
  "verses": [
    {
      "book_name": "Genesis",
      "book": 1,
      "chapter": 1,
      "verse": 1,
      "text": "In the beginning God created the heaven and the earth."
    }
  ]
}
```

## Required Decoding Models

Create internal decoding structs if needed:

```swift
struct KJVRoot: Codable {
    let metadata: KJVMetadata
    let verses: [KJVVerseDTO]
}

struct KJVMetadata: Codable {
    let name: String?
    let shortname: String?
    let module: String?
}

struct KJVVerseDTO: Codable {
    let bookName: String
    let book: Int
    let chapter: Int
    let verse: Int
    let text: String

    enum CodingKeys: String, CodingKey {
        case bookName = "book_name"
        case book
        case chapter
        case verse
        case text
    }
}
```

## Service Methods

```swift
func getAvailableVersions() -> [BibleVersion]
func getBooks(version: BibleVersion) -> [BibleBook]
func getChapters(book: BibleBook) -> [BibleChapter]
func getVerses(book: BibleBook, chapter: Int) -> [BibleVerse]
func getVerseRange(book: BibleBook, chapter: Int, startVerse: Int, endVerse: Int?) -> [BibleVerse]
```

## Service Behavior

The service should:

```text
Load kjv.json from the app bundle.
Decode the root metadata and verses array.
Return only KJV for now.
Group verses by book_name.
Sort books by their numeric book value.
Group chapters by chapter number.
Sort chapters in ascending order.
Sort verses in ascending verse order.
Support selecting one verse.
Support selecting a verse range.
```

## Important Xcode Requirement

Make sure `kjv.json` is included in the app bundle.

In Xcode, confirm:

```text
VerseFlip target
  ↓
Build Phases
  ↓
Copy Bundle Resources
  ↓
kjv.json is included
```

If `kjv.json` is not included in Copy Bundle Resources, the app will build but `LocalBibleService` will fail to load the file at runtime.

## Optional Text Cleanup

The KJV file may include formatting symbols like:

```text
¶
```

For now, keep the Bible text as-is unless it causes UI issues.

If needed, add a small helper later to clean display text:

```swift
func cleanedVerseText(_ text: String) -> String {
    text
        .replacingOccurrences(of: "¶ ", with: "")
        .replacingOccurrences(of: "¶", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)
}
```

Do not remove bracketed KJV words like:

```text
[is]
[was]
[and]
```

Those are part of the KJV formatting style and should remain unless the user requests otherwise.

## Testing References

After implementing the service, test that these references can be loaded from the full KJV file:

```text
Genesis 1:1
John 3:16
Psalm 23:1
Philippians 4:13
Romans 8:28
```

## Done When

```text
LocalBibleService loads ./VerseFlip/Data/kjv.json.
KJV appears as the available Bible version.
Books can be fetched from the JSON file.
Chapters can be fetched for a selected book.
Verses can be fetched for a selected chapter.
John 3 appears as available data.
John 3:16 can be fetched.
Psalm 23:1 can be fetched.
Philippians 4:13 can be fetched.
No external API is used.
No kjv_sample_bible.json is created unless kjv.json is missing.
The app does not crash if the JSON file fails to load.
A clear error or empty state is handled if kjv.json is missing from the bundle.
```

---


# Phase 6 — Add Verse Flow

## Goal

Build the complete Add Verse flow using the actual reference mockups.

## Codex Prompt

```text
Read verseflip-codex-phases-refactored.md and implement Phase 6 only.

Build the Add Verse flow using these references:
./UIMockups/03-add-verse-bible-version-screen.png
./UIMockups/04-book-selection-screen.png
./UIMockups/05-chapter-selection-screen.png
./UIMockups/06-verse-selection-screen.png
./UIMockups/07-preview-card-screen.png

Use LocalBibleService and KJV sample data. KJV should work. ESV and NIV should appear but be disabled or marked Coming Soon for now. Allow selecting one or multiple verses and previewing the flashcard before saving.
```

## Reference Images

```text
./UIMockups/03-add-verse-bible-version-screen.png
./UIMockups/04-book-selection-screen.png
./UIMockups/05-chapter-selection-screen.png
./UIMockups/06-verse-selection-screen.png
./UIMockups/07-preview-card-screen.png
```

## Files to Create or Update

```text
./VerseFlip/ViewModels/AddVerseViewModel.swift

./VerseFlip/Views/AddVerse/BibleVersionSelectionView.swift
./VerseFlip/Views/AddVerse/BookSelectionView.swift
./VerseFlip/Views/AddVerse/ChapterSelectionView.swift
./VerseFlip/Views/AddVerse/VerseSelectionView.swift
./VerseFlip/Views/AddVerse/VersePreviewView.swift
```

## Add Verse State

The view model should track:

```text
selectedVersion
selectedBook
selectedChapter
selectedVerses
selectedDeck
previewVerseText
previewReference
```

## Screen Requirements

### Bible Version Selection

```text
KJV enabled
ESV shown but disabled or Coming Soon
NIV shown but disabled or Coming Soon
```

### Book Selection

```text
Search book field
Old Testament section
New Testament section
Book rows
```

### Chapter Selection

```text
Grid of chapter buttons
Chapter 3 selectable for John
Continue button
```

### Verse Selection

```text
Verse rows with selection circles
Allow selecting John 3:16
Allow selecting John 3:16-17
Add Selected Verse button
```

### Preview Card

```text
Front Side: verse text
Back Side: reference, for example John 3:16 KJV
Deck selector
Save Card button
```

## Done When

```text
User can select KJV.
User can select John.
User can select chapter 3.
User can select John 3:16.
User can preview the card.
User can save the card.
Saved card is stored locally.
```

---

# Phase 7 — Library Screen and Deck UI

## Goal

Show saved cards and decks in the Library tab.

## Codex Prompt

```text
Read verseflip-codex-phases-refactored.md and implement Phase 7 only.

Build the Library screen using this reference:
./UIMockups/08-library-screen.png

Use real saved cards and decks from local storage. Show My Decks, saved verse rows, search, status chips, and a simple create deck UI.
```

## Reference Image

```text
./UIMockups/08-library-screen.png
```

## Files to Create or Update

```text
./VerseFlip/ViewModels/LibraryViewModel.swift

./VerseFlip/Views/Library/LibraryView.swift
./VerseFlip/Views/Library/DeckCardView.swift
./VerseFlip/Views/Library/SavedVerseRowView.swift
./VerseFlip/Views/Library/DeckDetailView.swift
./VerseFlip/Views/Library/CreateDeckView.swift
```

## Features

```text
Search saved verses
Show Default Deck
Show verse count per deck
Show saved verses
Show status chip per verse
Open deck detail
Create new deck
```

## Done When

```text
Saved verse cards appear in the Library.
Default Deck exists.
Deck count is correct.
Search filters saved verses.
Status chips display Learning, Reviewing, Memorized, or Difficult.
```

---

# Phase 8 — Review Flashcard Flow

## Goal

Implement the flip-card review screen and completion screen.

## Codex Prompt

```text
Read verseflip-codex-phases-refactored.md and implement Phase 8 only.

Build the Review flow using these references:
./UIMockups/09-review-flashcard-screen.png
./UIMockups/10-review-complete-screen.png

The flashcard should show the verse text on the front. Tapping the card should flip to show the reference. The user can mark Again, Good, or Memorized. Update and persist the review status.
```

## Reference Images

```text
./UIMockups/09-review-flashcard-screen.png
./UIMockups/10-review-complete-screen.png
```

## Files to Create or Update

```text
./VerseFlip/ViewModels/ReviewViewModel.swift

./VerseFlip/Views/Review/ReviewView.swift
./VerseFlip/Views/Review/FlipCardView.swift
./VerseFlip/Views/Review/ReviewCompleteView.swift
```

## Review Status Mapping

```text
Again      → Difficult
Good       → Reviewing
Memorized  → Memorized
```

## Review Screen Requirements

```text
Review title
Card 1 of N
Progress indicator
Large flashcard
Tap to reveal reference
Again button
Good button
Memorized button
Default Deck label
```

## Review Complete Requirements

```text
Great job!
You reviewed N verses today.
Remembered count
Need practice count
Back to Home
Review Again
```

## Done When

```text
User can review saved cards.
Card flips on tap.
Review buttons update status.
Status changes persist.
Review Complete screen appears after final card.
```

---

# Phase 9 — Home Screen Real Data

## Goal

Replace static Home data with real saved data.

## Codex Prompt

```text
Read verseflip-codex-phases-refactored.md and implement Phase 9 only.

Connect HomeView to real saved data. Replace static counts with values from saved VerseCards and ReviewStatus. Keep the UI visually the same as ./UIMockups/02-home-screen.png.
```

## Files to Create or Update

```text
./VerseFlip/ViewModels/HomeViewModel.swift
./VerseFlip/Views/Home/HomeView.swift
./VerseFlip/Views/Home/ProgressCardView.swift
```

## Dynamic Home Values

```text
Total saved verses
Cards due for review
Memorized cards
Learning/reviewing/difficult cards
```

## MVP Due Review Rule

```text
Due for review = all cards that are not Memorized
```

## Done When

```text
Home counts update after saving a card.
Home counts update after reviewing a card.
Start Review opens the review flow with due cards.
Quick Actions still work.
```

---

# Phase 10 — Profile and Settings

## Goal

Add a basic Profile screen.

## Codex Prompt

```text
Read verseflip-codex-phases-refactored.md and implement Phase 10 only.

Build a simple Profile screen with progress stats and basic settings placeholders. Keep the visual style consistent with the rest of VerseFlip.
```

## File to Update

```text
./VerseFlip/Views/Profile/ProfileView.swift
```

## Profile Content

```text
Total Saved Verses
Memorized
Learning
Current Streak placeholder
Preferred Bible Version
Daily Reminder placeholder
Dark Mode placeholder
Reset Progress button
```

## Requirements

```text
Use real counts where available.
Preferred Bible Version can be stored locally.
Daily Reminder can be UI-only for now.
Dark Mode can be UI-only for now.
Reset Progress must show confirmation alert.
```

## Done When

```text
Profile screen displays real stats.
Settings UI appears.
Reset progress has a confirmation alert.
App remains stable.
```

---

# Phase 11 — ESV and NIV API Readiness

## Goal

Prepare the service layer for future official API support.

## Codex Prompt

```text
Read verseflip-codex-phases-refactored.md and implement Phase 11 only.

Refactor the Bible service layer so VerseFlip can support local KJV and future API-backed ESV/NIV. Do not use unofficial Bible APIs. Do not hardcode copyrighted NIV or ESV text. Keep KJV working locally.
```

## Files to Create or Update

```text
./VerseFlip/Services/BibleServiceProtocol.swift
./VerseFlip/Services/LocalBibleService.swift
./VerseFlip/Services/BibleServiceFactory.swift
./VerseFlip/Services/ESVBibleAPIService.swift
./VerseFlip/Services/NIVBibleAPIService.swift
```

## Rules

```text
KJV uses local JSON.
ESV uses official API later.
NIV uses official licensed API later.
ESV/NIV should show unavailable state if API keys are missing.
Do not fake ESV or NIV Bible text.
```

## Done When

```text
KJV still works.
Service layer is version-aware.
ESV/NIV placeholders exist.
No copyrighted Bible text is bundled.
No unofficial APIs are used.
```

---

# Phase 12 — Polish and Testing

## Goal

Polish the MVP for demo quality.

## Codex Prompt

```text
Read verseflip-codex-phases-refactored.md and implement Phase 12 only.

Polish the VerseFlip MVP. Improve spacing, empty states, accessibility labels, errors, animations, and build stability. Do not add major new features.
```

## Polish Checklist

```text
Consistent spacing
Consistent corner radius
Consistent shadows
Readable text sizes
Accessible labels
Empty state for Library
Empty state for Review
Smooth card flip animation
No broken navigation
No duplicate color literals
No unused placeholder code that breaks flow
```

## Empty States

Library:

```text
No saved verses yet.
Add your first verse to begin memorizing Scripture.
```

Review:

```text
No cards due for review.
Add a verse or review your saved cards again.
```

## Testing Checklist

```text
App launches
Splash opens MainTabView
Home loads
Add Verse flow works
KJV John 3 loads
John 3:16 saves
Library displays saved card
Review card flips
Review status persists
Home counts update
App relaunch preserves saved data
```

## Done When

```text
The MVP works end to end.
The app visually matches the mockups.
The app is ready for demo.
```

---

# Recommended MVP Phase Order

Build in this order first:

```text
Phase 0 — Verify Current Project and Prepare Structure
Phase 1 — Theme and Reusable Components
Phase 2 — Models and Local Storage
Phase 3 — Navigation Shell
Phase 4 — Splash Screen and Home Screen
Phase 5 — Local KJV Bible Data Service
Phase 6 — Add Verse Flow
Phase 7 — Library Screen and Deck UI
Phase 8 — Review Flashcard Flow
Phase 9 — Home Screen Real Data
```

Then add:

```text
Phase 10 — Profile and Settings
Phase 11 — ESV and NIV API Readiness
Phase 12 — Polish and Testing
```

---

# One-Phase Codex Prompt Template

Use this template every time you ask Codex to work:

```text
Read verseflip-codex-phases-refactored.md and implement Phase [NUMBER] only.

Important:
- Use the actual project structure.
- UI mockups are located in ./UIMockups/.
- App source code is located in ./VerseFlip/.
- Do not create ./VerseFlip/DesignReferences/.
- Do not move ./UIMockups/.
- Do not implement future phases.
- Do not delete unrelated files.
- Keep the app buildable.
- After implementation, summarize changed files and issues.
```

Example:

```text
Read verseflip-codex-phases-refactored.md and implement Phase 6 only.

Important:
- Use the actual project structure.
- UI mockups are located in ./UIMockups/.
- App source code is located in ./VerseFlip/.
- Do not create ./VerseFlip/DesignReferences/.
- Do not move ./UIMockups/.
- Do not implement future phases.
- Do not delete unrelated files.
- Keep the app buildable.
- After implementation, summarize changed files and issues.
```

---

# Final MVP Acceptance Criteria

The MVP is complete when:

```text
User can open VerseFlip.
User can pass the Splash screen.
User can use the Home screen.
User can choose KJV.
User can browse John chapter 3.
User can select John 3:16.
User can preview the card.
User can save the card.
User can see it in Library.
User can review it as a flip card.
User can mark it Again, Good, or Memorized.
User can see progress update on Home.
```

---

# Future Improvements

```text
Spaced repetition algorithm
Daily reminders
iCloud sync
Custom decks
Verse search by keyword
Import verse by reference
Share verse card as image
Dark mode
Widgets
Streak tracking
Official ESV API support
Official NIV licensed API support
```
