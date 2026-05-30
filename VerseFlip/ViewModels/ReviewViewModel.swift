//
//  ReviewViewModel.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Combine
import Foundation

final class ReviewViewModel: ObservableObject {
    @Published private(set) var cards: [VerseCard] = []
    @Published private(set) var decks: [Deck] = []
    @Published private(set) var selectedDeck: Deck = .defaultDeck
    @Published private(set) var currentIndex = 0
    @Published private(set) var isFlipped = false
    @Published private(set) var isComplete = false
    @Published private(set) var reviewedCount = 0
    @Published private(set) var rememberedCount = 0
    @Published private(set) var needPracticeCount = 0
    @Published private(set) var errorMessage: String?

    private let verseCardStore: VerseCardStore
    private let deckStore: DeckStore
    private let reviewingDueOnly: Bool

    init(
        reviewingDueOnly: Bool = false,
        verseCardStore: VerseCardStore = VerseCardStore(),
        deckStore: DeckStore = DeckStore()
    ) {
        self.reviewingDueOnly = reviewingDueOnly
        self.verseCardStore = verseCardStore
        self.deckStore = deckStore
        reload()
    }

    var totalCount: Int {
        cards.count
    }

    var selectedDeckName: String {
        displayName(for: selectedDeck)
    }

    var currentCard: VerseCard? {
        guard cards.indices.contains(currentIndex), isComplete == false else {
            return nil
        }

        return cards[currentIndex]
    }

    var currentCardNumber: Int {
        guard totalCount > 0 else {
            return 0
        }

        return min(currentIndex + 1, totalCount)
    }

    var progressFraction: Double {
        guard totalCount > 0 else {
            return 0
        }

        return Double(currentIndex) / Double(totalCount)
    }

    func reload() {
        deckStore.reload()
        verseCardStore.reload()
        decks = deckStore.decks

        if let refreshedSelection = decks.first(where: { $0.id == selectedDeck.id }) {
            selectedDeck = refreshedSelection
        } else {
            selectedDeck = decks.first(where: { $0.id == Deck.defaultDeck.id }) ?? .defaultDeck
        }

        loadCardsForSelectedDeck(resetReview: true)
        errorMessage = nil
    }

    func selectDeck(_ deck: Deck) {
        selectedDeck = deck
        loadCardsForSelectedDeck(resetReview: true)
    }

    func toggleFlip() {
        isFlipped.toggle()
    }

    func deckName(for card: VerseCard) -> String {
        guard let deck = decks.first(where: { $0.id == card.deckId }) else {
            return "Default Deck"
        }

        return displayName(for: deck)
    }

    func displayName(for deck: Deck) -> String {
        deck.id == Deck.defaultDeck.id ? "Default Deck" : deck.name
    }

    func markAgain() {
        markCurrentCard(as: .difficult)
    }

    func markGood() {
        markCurrentCard(as: .reviewing)
    }

    func markMemorized() {
        markCurrentCard(as: .memorized)
    }

    func reviewAgain() {
        reload()
    }

    func clearError() {
        errorMessage = nil
    }

    private func loadCardsForSelectedDeck(resetReview: Bool) {
        let reviewCards = reviewingDueOnly
            ? verseCardStore.cards.filter { $0.reviewStatus != .memorized }
            : verseCardStore.cards

        cards = reviewCards
            .filter { $0.deckId == selectedDeck.id }
            .sorted { lhs, rhs in
                let lhsDate = lhs.lastReviewedAt ?? lhs.dateAdded
                let rhsDate = rhs.lastReviewedAt ?? rhs.dateAdded
                return lhsDate < rhsDate
            }

        guard resetReview else {
            currentIndex = min(currentIndex, max(cards.count - 1, 0))
            isComplete = cards.isEmpty
            return
        }

        currentIndex = 0
        isFlipped = false
        isComplete = false
        reviewedCount = 0
        rememberedCount = 0
        needPracticeCount = 0
    }

    private func markCurrentCard(as status: ReviewStatus) {
        guard var card = currentCard else {
            return
        }

        card.reviewStatus = status
        card.lastReviewedAt = Date()

        do {
            try verseCardStore.upsert(card)
            cards[currentIndex] = card
            reviewedCount += 1

            if status == .memorized {
                rememberedCount += 1
            } else {
                needPracticeCount += 1
            }

            advance()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func advance() {
        let nextIndex = currentIndex + 1
        isFlipped = false

        if nextIndex >= totalCount {
            isComplete = true
        } else {
            currentIndex = nextIndex
        }
    }
}
