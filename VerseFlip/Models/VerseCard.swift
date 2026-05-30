//
//  VerseCard.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

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

    init(
        id: UUID = UUID(),
        verseText: String,
        reference: String,
        book: String,
        chapter: Int,
        verseStart: Int,
        verseEnd: Int? = nil,
        bibleVersion: BibleVersion = .kjv,
        deckId: UUID = Deck.defaultDeck.id,
        reviewStatus: ReviewStatus = .learning,
        dateAdded: Date = Date(),
        lastReviewedAt: Date? = nil
    ) {
        self.id = id
        self.verseText = verseText
        self.reference = reference
        self.book = book
        self.chapter = chapter
        self.verseStart = verseStart
        self.verseEnd = verseEnd
        self.bibleVersion = bibleVersion
        self.deckId = deckId
        self.reviewStatus = reviewStatus
        self.dateAdded = dateAdded
        self.lastReviewedAt = lastReviewedAt
    }
}
