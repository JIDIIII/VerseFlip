//
//  HomeViewModel.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Combine
import Foundation

final class HomeViewModel: ObservableObject {
    @Published private(set) var cards: [VerseCard] = []

    private let verseCardStore: VerseCardStore

    init(verseCardStore: VerseCardStore = VerseCardStore()) {
        self.verseCardStore = verseCardStore
        reload()
    }

    var totalSavedVerses: Int {
        cards.count
    }

    var dueForReviewCount: Int {
        dueCards.count
    }

    var memorizedCount: Int {
        count(for: .memorized)
    }

    var learningCount: Int {
        count(for: .learning)
    }

    var reviewingCount: Int {
        count(for: .reviewing)
    }

    var difficultCount: Int {
        count(for: .difficult)
    }

    var dueCards: [VerseCard] {
        cards
            .filter { $0.reviewStatus != .memorized }
            .sorted { lhs, rhs in
                let lhsDate = lhs.lastReviewedAt ?? lhs.dateAdded
                let rhsDate = rhs.lastReviewedAt ?? rhs.dateAdded
                return lhsDate < rhsDate
            }
    }

    func reload() {
        verseCardStore.reload()
        cards = verseCardStore.cards
    }

    private func count(for status: ReviewStatus) -> Int {
        cards.filter { $0.reviewStatus == status }.count
    }
}
