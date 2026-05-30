# VerseFlip — Review Page and Library Management Fixes

Use this Markdown file as a focused Codex update prompt for fixing the current Review page issue and improving library/deck behavior.

This update is based on the current app screenshot where the Review screen content becomes oversized/zoomed when a card has long verse text.

---

# Update Goal

Fix the Review page layout and text behavior, improve review deck selection, allow deleting verses/decks, and update the first-time onboarding flow.

---

# Current Problems to Fix

## 1. Review Page Text Overflow

Current issue:

```text
The Review page becomes visually zoomed/cropped when the card contains a long verse or multiple verses.
Large verse text overflows horizontally and vertically.
Some content is cut off and cannot be read properly.
The tab bar remains visible but the card content is too large.
```

Expected behavior:

```text
The review card should always fit inside the screen.
Long verse text should shrink dynamically but stay readable.
The card should scroll internally only if absolutely necessary.
The whole screen should not appear zoomed or cropped.
```

---

## 2. Text Sizes Are Too Large

Current issue:

```text
Some text sizes are too large across the app, especially in Review.
Large serif text causes overflow.
```

Expected behavior:

```text
Reduce global display sizes slightly.
Keep the app elegant and readable.
Use dynamic text sizing where needed.
Avoid oversized headings or verse text.
```

---

## 3. Review Page Needs Deck/Pack Switching

Current issue:

```text
Review page currently reviews one default set/deck.
User cannot easily choose which library pack/deck to review.
```

Expected behavior:

```text
Review page should allow changing the active deck/pack.
User can select Default Deck or another created deck.
Review cards should update based on the selected deck.
```

---

## 4. Allow Verse and Pack Deletion

Current issue:

```text
User cannot delete a saved verse from a pack/deck.
User cannot delete a full pack/deck.
```

Expected behavior:

```text
User can delete a saved verse from a deck.
User can delete a whole deck/pack.
Deleting a deck should ask for confirmation.
Default Deck should either not be deletable or should be protected.
Deleting a verse should update Library, Review, and Home counts.
```

---

## 5. Get Started Should Only Show First Time

Current issue:

```text
Get Started / Splash onboarding may appear every time.
```

Expected behavior:

```text
Get Started should show only on first app launch or if no user profile/nickname exists.
After the user enters a nickname, app should open directly to MainTabView on future launches.
```

---

## 6. Add Nickname Input After Get Started

Expected behavior:

```text
After tapping Get Started, ask the user for a nickname.
Save the nickname locally.
Use the nickname in Home greeting.
Example: Good morning, JD
```

---

## 7. Interchange Front and Back Card Content

Current behavior:

```text
Front card = verse text
Back card = verse reference/version
```

New desired behavior:

```text
Front card = verse reference and Bible version
Back card = verse text
```

Example:

```text
Front:
Philippians 4:6-7 KJV

Back:
Be careful for nothing; but in every thing by prayer and supplication...
```

This makes the user recall the verse text from the reference.

---

# Codex Prompt

```text
Read this file and implement this update only.

Fix the Review page layout bug shown in the screenshot where long verse text causes the screen to zoom/crop. Make the review card support dynamic text sizing so long verses fit inside the screen while staying readable.

Also reduce app text sizes slightly where they are too large, add deck/pack switching on the Review page, allow deleting verses and decks, make Get Started appear only on first launch or when no nickname exists, add nickname input after Get Started, and swap the flashcard sides so the front shows the reference/version and the back shows the verse text.

Do not rewrite the whole project.
Do not remove existing working features.
Keep the current visual style: warm cream background, navy text, gold accents, rounded cards.
Keep the app buildable.
```

---

# Files Likely to Update

Codex should inspect the project first, then update only the necessary files.

Likely files:

```text
./VerseFlip/Views/Review/ReviewView.swift
./VerseFlip/Views/Review/FlipCardView.swift
./VerseFlip/Views/Review/ReviewCompleteView.swift
./VerseFlip/ViewModels/ReviewViewModel.swift

./VerseFlip/Views/Library/LibraryView.swift
./VerseFlip/Views/Library/DeckDetailView.swift
./VerseFlip/Views/Library/SavedVerseRowView.swift
./VerseFlip/Views/Library/DeckCardView.swift
./VerseFlip/ViewModels/LibraryViewModel.swift

./VerseFlip/Views/Splash/SplashView.swift
./VerseFlip/Views/Splash/NicknameView.swift
./VerseFlip/Views/Home/HomeView.swift
./VerseFlip/ContentView.swift

./VerseFlip/Storage/DeckStore.swift
./VerseFlip/Storage/VerseCardStore.swift
./VerseFlip/Storage/UserProfileStore.swift

./VerseFlip/Theme/VFFonts.swift
./VerseFlip/Components/VFCard.swift
./VerseFlip/Components/VFStatusChip.swift
```

If some files do not exist, create them only when needed.

---

# Part 1 — Fix Review Page Layout

## Requirements

The Review page must:

```text
Not crop horizontally.
Not make the whole screen feel zoomed in.
Respect safe areas.
Keep tab bar usable.
Keep review card inside screen bounds.
Work with short verses and long verse ranges.
```

## Implementation Guidance

Use a layout similar to this:

```swift
GeometryReader { geometry in
    ScrollView {
        VStack(spacing: 20) {
            // Header
            // Progress
            // FlipCardView
            // Action buttons
            // Deck selector
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}
```

Avoid fixed huge widths or heights that exceed screen size.

Avoid this kind of layout:

```swift
.frame(width: 900)
.font(.system(size: 64))
.scaleEffect(...)
```

---

# Part 2 — Dynamic Review Card Text Size

## Goal

Long card content should shrink depending on word count, but never become unreadable.

## New Card Side Behavior

Front side should show:

```text
Reference + Bible Version
```

Example:

```text
Philippians 4:6-7 KJV
```

Back side should show:

```text
Verse text
```

Example:

```text
Be careful for nothing; but in every thing by prayer and supplication...
```

## Dynamic Text Size Rules

Use a helper function for verse text size.

Suggested range:

```text
Maximum verse text size: 30
Medium verse text size: 24
Long verse text size: 20
Very long verse text size: 17
Minimum verse text size: 16
```

Suggested logic:

```swift
func verseTextSize(for text: String) -> CGFloat {
    let wordCount = text.split { $0.isWhitespace || $0.isNewline }.count

    switch wordCount {
    case 0...30:
        return 30
    case 31...60:
        return 24
    case 61...100:
        return 20
    default:
        return 17
    }
}
```

Important:

```text
Do not go below 16pt for readability.
Use .minimumScaleFactor(0.75) only as extra protection.
Use .lineLimit(nil).
Use .multilineTextAlignment(.center or .leading).
Use ScrollView inside the card only for very long text.
```

## Flip Card Layout

The card should:

```text
Have a fixed max height based on screen.
Use internal scrolling for very long verse text.
Use readable padding.
Center short content.
Allow long content to wrap.
Never overflow horizontally.
```

Suggested card constraints:

```swift
.frame(maxWidth: .infinity)
.frame(minHeight: 300)
.frame(maxHeight: min(geometry.size.height * 0.52, 460))
```

---

# Part 3 — Reduce App Text Sizes Slightly

## Goal

Make text sizes a bit smaller app-wide while preserving the elegant design.

## Requirements

Update `VFFonts.swift` or wherever font sizes are centralized.

Recommended sizes:

```text
Large screen title: 40 → 34
Main title: 34 → 30
Section title: 26 → 23
Card title: 22 → 20
Body: 17 → 16
Small body: 15 → 14
Caption: 13 → 12
Large verse text: dynamic, max 30
```

If fonts are not centralized yet, reduce only the obvious oversized Review page text first.

Do not make text too small.

---

# Part 4 — Add Review Deck/Pack Selector

## Goal

Allow users to choose which deck/pack to review from the Review page.

## Requirements

On the Review page, add a deck selector area similar to:

```text
Default Deck >
```

When tapped:

```text
Show a sheet or menu listing available decks.
Selecting a deck updates the review cards.
If selected deck has no cards, show empty state.
```

## Empty State

If selected deck has no review cards:

```text
No cards in this deck yet.
Add verses to this deck to start reviewing.
```

## ViewModel Requirements

ReviewViewModel should track:

```text
availableDecks
selectedDeck
cardsForSelectedDeck
currentCardIndex
isFlipped
```

Changing the selected deck should:

```text
Reset currentCardIndex to 0.
Reset isFlipped to false.
Reload cards for that deck.
Update progress indicator.
```

---

# Part 5 — Delete Verses from a Deck

## Goal

Allow users to delete a saved verse/card.

## Requirements

In Library and Deck Detail:

```text
Allow swipe-to-delete on saved verse rows.
Show confirmation before deleting if practical.
After deletion, remove the card from storage.
Update Library.
Update Home counts.
Update Review cards.
```

For SwiftUI List:

```swift
.onDelete { indexSet in
    // delete selected cards
}
```

If using custom ScrollView cards instead of List:

```text
Add a trash button or context menu.
```

## Context Menu Option

A saved verse row can support:

```swift
.contextMenu {
    Button(role: .destructive) {
        // delete card
    } label: {
        Label("Delete Verse", systemImage: "trash")
    }
}
```

---

# Part 6 — Delete Pack/Deck

## Goal

Allow deleting a whole deck/pack.

## Requirements

In Library or Deck Detail:

```text
Add delete deck option.
Show confirmation alert before deleting.
Delete all cards inside that deck or ask user what to do.
Protect Default Deck from deletion.
```

Recommended MVP behavior:

```text
Default Deck cannot be deleted.
Custom decks can be deleted.
When deleting a custom deck, delete all saved verse cards inside it.
```

Alert text:

```text
Delete Deck?
This will delete the deck and all verses saved inside it. This action cannot be undone.
```

Buttons:

```text
Cancel
Delete
```

After deletion:

```text
Return to Library.
Update Home counts.
If Review was using deleted deck, switch back to Default Deck.
```

---

# Part 7 — First-Time Get Started Logic

## Goal

Splash/Get Started should not appear every time.

## Requirements

Create simple local user profile/preference storage.

Suggested file:

```text
./VerseFlip/Storage/UserProfileStore.swift
```

Suggested model:

```swift
struct UserProfile: Codable {
    var nickname: String
    var hasCompletedOnboarding: Bool
}
```

Or use `@AppStorage` for MVP:

```swift
@AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
@AppStorage("userNickname") private var userNickname = ""
```

ContentView logic:

```text
If hasCompletedOnboarding == false OR userNickname is empty:
    Show Splash/Get Started + nickname flow
Else:
    Show MainTabView
```

---

# Part 8 — Nickname Input After Get Started

## Goal

After tapping Get Started, ask the user to enter a nickname.

## Flow

```text
SplashView
  ↓ tap Get Started
NicknameView
  ↓ enter nickname
MainTabView
```

## New View

Create if needed:

```text
./VerseFlip/Views/Splash/NicknameView.swift
```

## Nickname Screen Requirements

Show:

```text
What should we call you?
Enter your nickname
Continue
```

Validation:

```text
Nickname cannot be empty.
Trim whitespace.
Limit nickname to around 20 characters.
```

After saving:

```text
Save nickname locally.
Set hasCompletedOnboarding = true.
Navigate to MainTabView.
```

Home greeting:

```text
Good morning, {nickname}
```

Fallback:

```text
Good morning
```

---

# Part 9 — Flashcard Side Swap

## Required Behavior

Change the review card sides:

```text
Front = reference and version
Back = full verse text
```

Example front:

```text
Philippians 4:6-7 KJV
```

Example back:

```text
Be careful for nothing; but in every thing by prayer and supplication with thanksgiving...
```

## UI Label Change

When front is showing:

```text
FRONT
Tap to reveal verse
```

When back is showing:

```text
BACK
Tap to show reference
```

## Button Behavior

The review buttons should still work:

```text
Again
Good
Memorized
```

The user should preferably flip to the verse before rating, but do not block rating unless already implemented that way.

---

# Part 10 — Data Consistency

After these updates, make sure:

```text
Deleting a verse removes it from all relevant views.
Deleting a deck removes cards in that deck.
Changing review deck updates review cards.
Home counts update after delete/review.
Library updates after delete.
Review page does not crash if current card gets deleted.
```

---

# Done When

This update is complete when:

```text
Review page no longer zooms/crops on long verses.
Long verse text fits inside the review card.
Text size dynamically shrinks but stays readable.
General text sizes are slightly smaller and cleaner.
Review page can change selected deck/pack.
User can delete saved verses.
User can delete custom decks/packs.
Default Deck is protected from deletion.
Splash/Get Started only appears on first launch or when nickname is missing.
After Get Started, user can input nickname.
Home uses saved nickname in greeting.
Flashcard front shows reference/version.
Flashcard back shows verse text.
App builds successfully.
App runs without crashing.
Existing add verse and library flows still work.
```

---

# Manual Test Checklist

After Codex implements this update, test:

```text
[ ] Fresh install opens SplashView.
[ ] Tap Get Started.
[ ] Nickname screen appears.
[ ] Empty nickname cannot continue.
[ ] Enter nickname.
[ ] Main app opens.
[ ] Close and reopen app.
[ ] Splash/Get Started does not appear again.
[ ] Home greeting uses nickname.
[ ] Add a short verse card.
[ ] Add a long verse or multi-verse card.
[ ] Open Review.
[ ] Review card does not zoom/crop.
[ ] Front side shows reference/version.
[ ] Tap card.
[ ] Back side shows verse text.
[ ] Long verse text fits and remains readable.
[ ] Change review deck.
[ ] Review cards update for selected deck.
[ ] Delete a verse from Library or Deck Detail.
[ ] Deleted verse disappears.
[ ] Home counts update.
[ ] Delete a custom deck.
[ ] Confirmation alert appears.
[ ] Default Deck cannot be deleted.
[ ] App still builds and runs.
```

---

# Recommended Git Commit

After this update works:

```bash
git add .
git commit -m "Fix review layout and add deck management improvements"
```
