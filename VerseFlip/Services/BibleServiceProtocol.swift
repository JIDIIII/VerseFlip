//
//  BibleServiceProtocol.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

enum BibleServiceAvailability: Equatable {
    case available
    case unavailable(reason: String)

    var isAvailable: Bool {
        switch self {
        case .available:
            return true
        case .unavailable:
            return false
        }
    }

    var reason: String? {
        switch self {
        case .available:
            return nil
        case .unavailable(let reason):
            return reason
        }
    }
}

protocol BibleVersionServiceProtocol {
    var version: BibleVersion { get }
    var availability: BibleServiceAvailability { get }

    func getBooks() -> [BibleBook]
    func getChapters(book: BibleBook) -> [BibleChapter]
    func getVerses(book: BibleBook, chapter: Int) -> [BibleVerse]
    func getVerseRange(book: BibleBook, chapter: Int, startVerse: Int, endVerse: Int?) -> [BibleVerse]
}

protocol BibleServiceProtocol {
    func getAvailableVersions() -> [BibleVersion]
    func getAvailability(for version: BibleVersion) -> BibleServiceAvailability
    func getBooks(version: BibleVersion) -> [BibleBook]
    func getChapters(version: BibleVersion, book: BibleBook) -> [BibleChapter]
    func getVerses(version: BibleVersion, book: BibleBook, chapter: Int) -> [BibleVerse]
    func getVerseRange(version: BibleVersion, book: BibleBook, chapter: Int, startVerse: Int, endVerse: Int?) -> [BibleVerse]
}

extension BibleVersionServiceProtocol {
    func getVerseRange(book: BibleBook, chapter: Int, startVerse: Int, endVerse: Int?) -> [BibleVerse] {
        let lastVerse = endVerse ?? startVerse
        let lowerBound = min(startVerse, lastVerse)
        let upperBound = max(startVerse, lastVerse)

        return getVerses(book: book, chapter: chapter).filter { verse in
            lowerBound...upperBound ~= verse.number
        }
    }
}

extension BibleServiceProtocol {
    func getChapters(book: BibleBook) -> [BibleChapter] {
        getChapters(version: .kjv, book: book)
    }

    func getVerses(book: BibleBook, chapter: Int) -> [BibleVerse] {
        getVerses(version: .kjv, book: book, chapter: chapter)
    }

    func getVerseRange(book: BibleBook, chapter: Int, startVerse: Int, endVerse: Int?) -> [BibleVerse] {
        getVerseRange(version: .kjv, book: book, chapter: chapter, startVerse: startVerse, endVerse: endVerse)
    }
}
