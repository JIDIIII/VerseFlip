//
//  LibraryViewModel.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Combine
import Foundation

final class LibraryViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var decks: [Deck] = []
    @Published private(set) var cards: [VerseCard] = []
    @Published private(set) var errorMessage: String?

    private let deckStore: DeckStore
    private let verseCardStore: VerseCardStore

    init(
        deckStore: DeckStore = DeckStore(),
        verseCardStore: VerseCardStore = VerseCardStore()
    ) {
        self.deckStore = deckStore
        self.verseCardStore = verseCardStore
        reload()
    }

    var filteredCards: [VerseCard] {
        let sortedCards = cards.sorted { $0.dateAdded > $1.dateAdded }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard query.isEmpty == false else {
            return sortedCards
        }

        return sortedCards.filter { card in
            [
                card.reference,
                card.verseText,
                card.book,
                card.bibleVersion.rawValue,
                card.reviewStatus.title,
                deckName(for: card.deckId)
            ]
            .joined(separator: " ")
            .lowercased()
            .contains(query)
        }
    }

    var savedVerseSummary: String {
        cards.count == 1 ? "1 saved verse" : "\(cards.count) saved verses"
    }

    func reload() {
        deckStore.reload()
        verseCardStore.reload()
        decks = deckStore.decks
        cards = verseCardStore.cards
    }

    func cards(in deck: Deck) -> [VerseCard] {
        cards
            .filter { $0.deckId == deck.id }
            .sorted { $0.dateAdded > $1.dateAdded }
    }

    func cardCount(for deck: Deck) -> Int {
        cards.filter { $0.deckId == deck.id }.count
    }

    func deckName(for deckId: UUID) -> String {
        guard let deck = decks.first(where: { $0.id == deckId }) else {
            return "Unknown Deck"
        }

        return displayName(for: deck)
    }

    func displayName(for deck: Deck) -> String {
        deck.id == Deck.defaultDeck.id ? "Default Deck" : deck.name
    }

    func createDeck(name: String, iconName: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.isEmpty == false else {
            errorMessage = "Enter a deck name."
            return
        }

        do {
            _ = try deckStore.createDeck(name: trimmedName, iconName: iconName)
            reload()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func canDelete(_ deck: Deck) -> Bool {
        deck.id != Deck.defaultDeck.id
    }

    func deleteCard(_ card: VerseCard) {
        do {
            try verseCardStore.deleteCard(id: card.id)
            reload()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteDeck(_ deck: Deck) {
        guard canDelete(deck) else {
            errorMessage = "Default Deck cannot be deleted."
            return
        }

        do {
            try verseCardStore.deleteCards(in: deck.id)
            try deckStore.deleteDeck(id: deck.id)
            reload()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
