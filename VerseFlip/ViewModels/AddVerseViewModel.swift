//
//  AddVerseViewModel.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation
import Combine

final class AddVerseViewModel: ObservableObject {
    @Published var selectedVersion: BibleVersion?
    @Published var selectedBook: BibleBook?
    @Published var selectedChapter: Int?
    @Published var selectedVerses: Set<Int> = []
    @Published var selectedDeck: Deck
    @Published private(set) var books: [BibleBook] = []
    @Published private(set) var chapters: [BibleChapter] = []
    @Published private(set) var verses: [BibleVerse] = []
    @Published private(set) var decks: [Deck] = []
    @Published private(set) var saveErrorMessage: String?
    @Published private(set) var didSaveCard = false

    private let bibleService: BibleServiceProtocol
    private let deckStore: DeckStore
    private let verseCardStore: VerseCardStore

    init(
        bibleService: BibleServiceProtocol = BibleServiceFactory.makeDefaultService(),
        deckStore: DeckStore = DeckStore(),
        verseCardStore: VerseCardStore = VerseCardStore()
    ) {
        self.bibleService = bibleService
        self.deckStore = deckStore
        self.verseCardStore = verseCardStore
        self.decks = deckStore.decks
        self.selectedDeck = deckStore.decks.first ?? Deck.defaultDeck

        if bibleService.getAvailableVersions().contains(.kjv) {
            selectVersion(.kjv)
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
        selectedVerseList
            .map(\.text)
            .joined(separator: " ")
            .replacingOccurrences(of: "¶ ", with: "")
    }

    var previewReference: String {
        guard let bookName = selectedBook?.name,
              let chapter = selectedChapter,
              let version = selectedVersion,
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

        return "\(bookName) \(chapter):\(verseReference) \(version.rawValue)"
    }

    var canContinueFromVersion: Bool {
        guard let selectedVersion else {
            return false
        }

        return bibleService.getAvailability(for: selectedVersion).isAvailable && books.isEmpty == false
    }

    var canContinueFromChapter: Bool {
        selectedChapter != nil
    }

    var canPreviewSelection: Bool {
        selectedVerseList.isEmpty == false
    }

    func isVersionEnabled(_ version: BibleVersion) -> Bool {
        bibleService.getAvailability(for: version).isAvailable
    }

    func versionStatusText(_ version: BibleVersion) -> String? {
        isVersionEnabled(version) ? nil : "Unavailable"
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
        books = bibleService.getBooks(version: version)
    }

    func selectBook(_ book: BibleBook) {
        selectedBook = book
        selectedChapter = nil
        selectedVerses = []
        verses = []
        chapters = bibleService.getChapters(version: selectedVersion ?? .kjv, book: book)
    }

    func selectChapter(_ chapter: Int) {
        guard let selectedBook else {
            return
        }

        selectedChapter = chapter
        selectedVerses = []
        verses = bibleService.getVerses(version: selectedVersion ?? .kjv, book: selectedBook, chapter: chapter)
    }

    func toggleVerse(_ verse: BibleVerse) {
        if selectedVerses.contains(verse.number) {
            selectedVerses.remove(verse.number)
        } else {
            selectedVerses.insert(verse.number)
        }
    }

    func isVerseSelected(_ verse: BibleVerse) -> Bool {
        selectedVerses.contains(verse.number)
    }

    func saveCard() {
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

    func clearSaveConfirmation() {
        didSaveCard = false
    }
}
