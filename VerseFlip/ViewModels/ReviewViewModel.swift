//
//  ReviewViewModel.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Combine
import Foundation

struct PreloadedReviewCard: Identifiable {
    let index: Int
    let card: VerseCard

    var id: UUID {
        card.id
    }
}

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
    private var sessionReviewResults: [UUID: ReviewStatus] = [:]

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

    var selectedCardIndex: Int {
        currentIndex
    }

    var selectedCardID: UUID? {
        currentCard?.id
    }

    var selectedDeckName: String {
        displayName(for: selectedDeck)
    }

    var cardsForSelectedDeck: [VerseCard] {
        cards
    }

    var preloadRadius: Int {
        Self.preloadRadius(for: totalCount)
    }

    var visiblePreloadedCards: [PreloadedReviewCard] {
        Self.preloadedCards(cards: cards, currentIndex: currentIndex, radius: preloadRadius)
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

    var canMoveToPreviousCard: Bool {
        currentIndex > 0 && isComplete == false
    }

    var canMoveToNextCard: Bool {
        currentIndex < totalCount - 1 && isComplete == false
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

    func setSelectedCardIndex(_ index: Int) {
        guard cards.isEmpty == false, isComplete == false else {
            return
        }

        let clampedIndex = clampedCardIndex(index)
        guard clampedIndex != currentIndex else {
            return
        }

        currentIndex = clampedIndex
        isFlipped = false
    }

    func moveToPreviousCard() {
        guard canMoveToPreviousCard else {
            return
        }

        setSelectedCardIndex(currentIndex - 1)
    }

    func moveToNextCard() {
        guard canMoveToNextCard else {
            return
        }

        setSelectedCardIndex(currentIndex + 1)
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
            currentIndex = clampedCardIndex(currentIndex)
            isComplete = false
            isFlipped = false
            return
        }

        currentIndex = 0
        isFlipped = false
        isComplete = false
        reviewedCount = 0
        rememberedCount = 0
        needPracticeCount = 0
        sessionReviewResults = [:]
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
            sessionReviewResults[card.id] = status
            updateSessionCounts()
            advanceAfterRating(from: currentIndex)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func clampedCardIndex(_ index: Int) -> Int {
        guard cards.isEmpty == false else {
            return 0
        }

        return min(max(index, 0), cards.count - 1)
    }

    private func updateSessionCounts() {
        reviewedCount = sessionReviewResults.count
        rememberedCount = sessionReviewResults.values.filter { $0 == .memorized }.count
        needPracticeCount = reviewedCount - rememberedCount
    }

    private func advanceAfterRating(from ratedIndex: Int) {
        isFlipped = false

        guard reviewedCount < totalCount else {
            isComplete = true
            return
        }

        if let nextUnreviewedIndex = nextUnreviewedCardIndex(after: ratedIndex) {
            currentIndex = nextUnreviewedIndex
            return
        }

        isComplete = true
    }

    private func nextUnreviewedCardIndex(after index: Int) -> Int? {
        guard cards.isEmpty == false else {
            return nil
        }

        let trailingIndices = cards.indices.dropFirst(index + 1)
        if let nextIndex = trailingIndices.first(where: { sessionReviewResults[cards[$0].id] == nil }) {
            return nextIndex
        }

        return cards.indices.prefix(index).first(where: { sessionReviewResults[cards[$0].id] == nil })
    }

    static func preloadRadius(for totalCards: Int) -> Int {
        switch totalCards {
        case 0...5:
            return totalCards
        case 6...15:
            return 3
        case 16...50:
            return 4
        case 51...150:
            return 5
        default:
            return 6
        }
    }

    static func preloadedCards(
        cards: [VerseCard],
        currentIndex: Int,
        radius: Int
    ) -> [PreloadedReviewCard] {
        guard cards.isEmpty == false else {
            return []
        }

        let clampedIndex = min(max(currentIndex, cards.startIndex), cards.index(before: cards.endIndex))
        let startIndex = max(cards.startIndex, clampedIndex - radius)
        let endIndex = min(cards.index(before: cards.endIndex), clampedIndex + radius)

        return (startIndex...endIndex).map { index in
            PreloadedReviewCard(index: index, card: cards[index])
        }
    }
}
