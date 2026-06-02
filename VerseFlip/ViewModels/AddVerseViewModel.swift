//
//  AddVerseViewModel.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation
import Combine

@MainActor
final class AddVerseViewModel: ObservableObject {
    @Published var selectedVersion: BibleVersion?
    @Published var selectedBook: BibleBook?
    @Published var selectedChapter: Int?
    @Published var selectedVerses: Set<Int> = []
    @Published var selectedDeck: Deck
    @Published var referenceInput = ""
    @Published private(set) var books: [BibleBook] = []
    @Published private(set) var chapters: [BibleChapter] = []
    @Published private(set) var verses: [BibleVerse] = []
    @Published private(set) var decks: [Deck] = []
    @Published private(set) var isFetchingPassage = false
    @Published private(set) var passageFetchErrorMessage: String?
    @Published private(set) var fetchedPassageText = ""
    @Published private(set) var fetchedPassageReference = ""
    @Published private(set) var saveErrorMessage: String?
    @Published private(set) var didSaveCard = false

    private let bibleService: BibleServiceProtocol
    private let deckStore: DeckStore
    private let verseCardStore: VerseCardStore

    init(
        bibleService: BibleServiceProtocol? = nil,
        deckStore: DeckStore? = nil,
        verseCardStore: VerseCardStore? = nil,
        preferredVersionRawValue: String? = UserDefaults.standard.string(forKey: "preferredBibleVersion")
    ) {
        let bibleService = bibleService ?? BibleServiceFactory.makeDefaultService()
        let deckStore = deckStore ?? DeckStore()
        let verseCardStore = verseCardStore ?? VerseCardStore()

        self.bibleService = bibleService
        self.deckStore = deckStore
        self.verseCardStore = verseCardStore
        self.decks = deckStore.decks
        self.selectedDeck = deckStore.decks.first ?? Deck.defaultDeck

        let preferredVersion = preferredVersionRawValue.flatMap(BibleVersion.init(rawValue:)) ?? .kjv
        let initialVersion = bibleService.getAvailableVersions().contains(preferredVersion) ? preferredVersion : .kjv

        if bibleService.getAvailableVersions().contains(initialVersion) {
            selectVersion(initialVersion)
        }
    }

    var versionOptions: [BibleVersion] {
        BibleVersion.allCases
    }

    var serviceMessage: String? {
        let kjvAvailability = bibleService.getAvailability(for: .kjv)
        if kjvAvailability.isAvailable == false {
            return kjvAvailability.reason ?? "KJV data is unavailable right now."
        }

        return nil
    }

    var selectedVerseList: [BibleVerse] {
        verses
            .filter { selectedVerses.contains($0.number) }
            .sorted { $0.number < $1.number }
    }

    var previewVerseText: String {
        if selectedVersionRequiresFetch {
            return fetchedPassageText
        }

        return selectedVerseList
            .map(\.text)
            .joined(separator: " ")
            .replacingOccurrences(of: "¶ ", with: "")
    }

    var previewReference: String {
        if selectedVersionRequiresFetch {
            guard let selectedVersion else { return "" }
            let reference = fetchedPassageReference.isEmpty ? selectedPassageReference : fetchedPassageReference
            return reference.isEmpty ? "" : "\(reference) \(selectedVersion.rawValue)"
        }

        guard let version = selectedVersion else { return "" }
        let reference = selectedPassageReference
        return reference.isEmpty ? "" : "\(reference) \(version.rawValue)"
    }

    var canContinueFromVersion: Bool {
        guard let selectedVersion else {
            return false
        }

        switch selectedVersion {
        case .kjv, .esv, .niv:
            return bibleService.getAvailability(for: selectedVersion).isAvailable && books.isEmpty == false
        }
    }

    var canContinueFromChapter: Bool {
        selectedChapter != nil
    }

    var canPreviewSelection: Bool {
        return selectedVerseList.isEmpty == false
    }

    var canFetchReference: Bool {
        referenceInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && isFetchingPassage == false
    }

    func isVersionEnabled(_ version: BibleVersion) -> Bool {
        bibleService.getAvailability(for: version).isAvailable
    }

    func versionStatusText(_ version: BibleVersion) -> String? {
        if isVersionEnabled(version) {
            return nil
        }

        switch version {
        case .kjv:
            return "Unavailable"
        case .esv:
            return "API Key Missing"
        case .niv:
            return "API Key Missing"
        }
    }

    func versionUnavailableMessage(_ version: BibleVersion) -> String? {
        bibleService.getAvailability(for: version).reason
    }

    func selectVersion(_ version: BibleVersion) {
        guard isVersionEnabled(version) else {
            return
        }

        selectedVersion = version
        selectedBook = nil
        selectedChapter = nil
        selectedVerses = []
        chapters = []
        verses = []
        clearFetchedPassage()
        books = bibleService.getBooks(version: version)
    }

    func selectBook(_ book: BibleBook) {
        selectedBook = book
        selectedChapter = nil
        selectedVerses = []
        verses = []
        clearFetchedPassage()
        chapters = bibleService.getChapters(version: selectedVersion ?? .kjv, book: book)
    }

    func selectChapter(_ chapter: Int) {
        guard let selectedBook else {
            return
        }

        selectedChapter = chapter
        selectedVerses = []
        clearFetchedPassage()
        verses = bibleService.getVerses(version: selectedVersion ?? .kjv, book: selectedBook, chapter: chapter)
    }

    func toggleVerse(_ verse: BibleVerse) {
        if selectedVerses.contains(verse.number) {
            selectedVerses.remove(verse.number)
        } else {
            selectedVerses.insert(verse.number)
        }

        if selectedVersionRequiresFetch {
            clearFetchedPassage(keepingInput: true)
        }
    }

    func isVerseSelected(_ verse: BibleVerse) -> Bool {
        selectedVerses.contains(verse.number)
    }

    @discardableResult
    func fetchReference(_ reference: String? = nil) async -> Bool {
        guard let versionToFetch = selectedVersion else {
            passageFetchErrorMessage = "Choose a Bible version before fetching."
            return false
        }

        let trimmedReference = (reference ?? referenceInput).trimmingCharacters(in: .whitespacesAndNewlines)
        referenceInput = trimmedReference
        clearFetchedPassage(keepingInput: true)

        guard trimmedReference.isEmpty == false else {
            passageFetchErrorMessage = "Please enter a Bible reference."
            return false
        }

        isFetchingPassage = true
        defer {
            isFetchingPassage = false
        }

        do {
            let draft = try await bibleService.fetchPassage(version: versionToFetch, reference: trimmedReference)
            fetchedPassageText = draft.verseText
            fetchedPassageReference = draft.reference
            selectedVersion = draft.bibleVersion
            passageFetchErrorMessage = nil
            return true
        } catch {
            passageFetchErrorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func fetchSelectedPassage() async -> Bool {
        let reference = selectedPassageReference
        guard reference.isEmpty == false else {
            passageFetchErrorMessage = "Select a verse before previewing."
            return false
        }

        return await fetchReference(reference)
    }

    func saveCard() {
        if selectedVersionRequiresFetch {
            saveFetchedCard()
            return
        }

        guard let selectedVersion,
              let selectedBook,
              let selectedChapter,
              let firstVerse = selectedVerseList.first
        else {
            saveErrorMessage = "Select a verse before saving."
            return
        }

        let verseNumbers = selectedVerseList.map(\.number)
        let isContinuousRange: Bool
        if let lastVerse = verseNumbers.last {
            isContinuousRange = verseNumbers == Array(firstVerse.number...lastVerse)
        } else {
            isContinuousRange = false
        }

        let card = VerseCard(
            verseText: previewVerseText,
            reference: previewReference,
            book: selectedBook.name,
            chapter: selectedChapter,
            verseStart: firstVerse.number,
            verseEnd: isContinuousRange && verseNumbers.count > 1 ? verseNumbers.last : nil,
            bibleVersion: selectedVersion,
            deckId: selectedDeck.id,
            reviewStatus: .learning
        )

        do {
            try verseCardStore.add(card)
            didSaveCard = true
            saveErrorMessage = nil
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }

    func clearSaveError() {
        saveErrorMessage = nil
    }

    func clearPassageFetchError() {
        passageFetchErrorMessage = nil
    }

    func clearSaveConfirmation() {
        didSaveCard = false
    }

    private func clearFetchedPassage(keepingInput: Bool = false) {
        if keepingInput == false {
            referenceInput = ""
        }

        fetchedPassageText = ""
        fetchedPassageReference = ""
        passageFetchErrorMessage = nil
    }

    var selectedVersionRequiresFetch: Bool {
        selectedVersion == .esv || selectedVersion == .niv
    }

    private var selectedPassageReference: String {
        guard let bookName = selectedBook?.name,
              let chapter = selectedChapter,
              let firstVerse = selectedVerseList.first
        else {
            return ""
        }

        let verseNumbers = selectedVerseList.map(\.number)
        let verseReference: String

        if let lastVerse = verseNumbers.last,
           verseNumbers == Array(firstVerse.number...lastVerse) {
            verseReference = firstVerse.number == lastVerse
                ? "\(firstVerse.number)"
                : "\(firstVerse.number)-\(lastVerse)"
        } else {
            verseReference = verseNumbers
                .map(String.init)
                .joined(separator: ", ")
        }

        return "\(bookName) \(chapter):\(verseReference)"
    }

    private func saveFetchedCard() {
        guard let selectedVersion else {
            saveErrorMessage = "Choose a Bible version before saving."
            return
        }

        guard fetchedPassageText.isEmpty == false,
              fetchedPassageReference.isEmpty == false else {
            saveErrorMessage = "Fetch a \(selectedVersion.rawValue) passage before saving."
            return
        }

        let referenceParts = BibleReferenceParser.parse(fetchedPassageReference)
        let card = VerseCard(
            verseText: fetchedPassageText,
            reference: previewReference,
            book: referenceParts?.book ?? fetchedPassageReference,
            chapter: referenceParts?.chapter ?? 0,
            verseStart: referenceParts?.verseStart ?? 0,
            verseEnd: referenceParts?.verseEnd,
            bibleVersion: selectedVersion,
            deckId: selectedDeck.id,
            reviewStatus: .learning
        )

        do {
            try verseCardStore.add(card)
            didSaveCard = true
            saveErrorMessage = nil
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }
}

private struct BibleReferenceParts {
    let book: String
    let chapter: Int
    let verseStart: Int
    let verseEnd: Int?
}

private enum BibleReferenceParser {
    static func parse(_ reference: String) -> BibleReferenceParts? {
        let pattern = #"^\s*([1-3]?\s?[A-Za-z]+(?:\s+[A-Za-z]+)*)\s+(\d+):(\d+)(?:\s*[-–]\s*(?:(\d+):)?(\d+))?"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }

        let range = NSRange(reference.startIndex..<reference.endIndex, in: reference)
        guard let match = regex.firstMatch(in: reference, range: range),
              let bookRange = Range(match.range(at: 1), in: reference),
              let chapterRange = Range(match.range(at: 2), in: reference),
              let verseStartRange = Range(match.range(at: 3), in: reference),
              let chapter = Int(reference[chapterRange]),
              let verseStart = Int(reference[verseStartRange]) else {
            return nil
        }

        let endChapterRange = Range(match.range(at: 4), in: reference)
        let endVerseRange = Range(match.range(at: 5), in: reference)
        let endVerse: Int?

        if let endVerseRange,
           endChapterRange == nil || Int(reference[endChapterRange!]) == chapter {
            endVerse = Int(reference[endVerseRange])
        } else {
            endVerse = nil
        }

        return BibleReferenceParts(
            book: String(reference[bookRange]),
            chapter: chapter,
            verseStart: verseStart,
            verseEnd: endVerse
        )
    }
}
