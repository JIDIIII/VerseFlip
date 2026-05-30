//
//  LocalBibleService.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

final class LocalBibleService: BibleVersionServiceProtocol, BibleServiceProtocol {
    let version = BibleVersion.kjv

    private let books: [BibleBook]
    private let chaptersByBookName: [String: [BibleChapter]]
    private let versesByBookAndChapter: [String: [Int: [BibleVerse]]]

    private(set) var loadError: Error?

    convenience init(bundle: Bundle = .main) {
        guard let url = bundle.url(forResource: "kjv", withExtension: "json") else {
            self.init(loadError: LocalBibleServiceError.missingResource("kjv.json"))
            return
        }

        self.init(jsonURL: url)
    }

    init(jsonURL: URL) {
        do {
            let data = try Data(contentsOf: jsonURL)
            let root = try JSONDecoder().decode(KJVRoot.self, from: data)
            let groupedBible = Self.groupVerses(root.verses)

            self.books = groupedBible.books
            self.chaptersByBookName = groupedBible.chaptersByBookName
            self.versesByBookAndChapter = groupedBible.versesByBookAndChapter
            self.loadError = nil
        } catch {
            self.books = []
            self.chaptersByBookName = [:]
            self.versesByBookAndChapter = [:]
            self.loadError = error
        }
    }

    private init(loadError: Error) {
        self.books = []
        self.chaptersByBookName = [:]
        self.versesByBookAndChapter = [:]
        self.loadError = loadError
    }

    var availability: BibleServiceAvailability {
        if let loadError {
            return .unavailable(reason: loadError.localizedDescription)
        }

        return books.isEmpty
            ? .unavailable(reason: "KJV data is unavailable right now.")
            : .available
    }

    func getAvailableVersions() -> [BibleVersion] {
        availability.isAvailable ? [.kjv] : []
    }

    func getAvailability(for version: BibleVersion) -> BibleServiceAvailability {
        guard version == .kjv else {
            return .unavailable(reason: "\(version.rawValue) is not available from the local KJV service.")
        }

        return availability
    }

    func getBooks() -> [BibleBook] {
        availability.isAvailable ? books : []
    }

    func getBooks(version: BibleVersion) -> [BibleBook] {
        version == .kjv ? getBooks() : []
    }

    func getChapters(version: BibleVersion, book: BibleBook) -> [BibleChapter] {
        version == .kjv ? getChapters(book: book) : []
    }

    func getChapters(book: BibleBook) -> [BibleChapter] {
        chaptersByBookName[book.name] ?? []
    }

    func getVerses(version: BibleVersion, book: BibleBook, chapter: Int) -> [BibleVerse] {
        version == .kjv ? getVerses(book: book, chapter: chapter) : []
    }

    func getVerses(book: BibleBook, chapter: Int) -> [BibleVerse] {
        versesByBookAndChapter[book.name]?[chapter] ?? []
    }

    func getVerseRange(book: BibleBook, chapter: Int, startVerse: Int, endVerse: Int?) -> [BibleVerse] {
        let lastVerse = endVerse ?? startVerse
        let lowerBound = min(startVerse, lastVerse)
        let upperBound = max(startVerse, lastVerse)

        return getVerses(book: book, chapter: chapter).filter { verse in
            lowerBound...upperBound ~= verse.number
        }
    }

    func getVerseRange(version: BibleVersion, book: BibleBook, chapter: Int, startVerse: Int, endVerse: Int?) -> [BibleVerse] {
        version == .kjv
            ? getVerseRange(book: book, chapter: chapter, startVerse: startVerse, endVerse: endVerse)
            : []
    }
}

private extension LocalBibleService {
    struct GroupedBible {
        let books: [BibleBook]
        let chaptersByBookName: [String: [BibleChapter]]
        let versesByBookAndChapter: [String: [Int: [BibleVerse]]]
    }

    static func groupVerses(_ verseDTOs: [KJVVerseDTO]) -> GroupedBible {
        let groupedByBook = Dictionary(grouping: verseDTOs, by: \.bookName)
        let bookOrderByName = Dictionary(
            verseDTOs.map { ($0.bookName, $0.book) },
            uniquingKeysWith: min
        )

        var chaptersByBookName: [String: [BibleChapter]] = [:]
        var versesByBookAndChapter: [String: [Int: [BibleVerse]]] = [:]

        let books = groupedByBook
            .map { bookName, bookVerses -> BibleBook in
                let bookNumber = bookOrderByName[bookName] ?? Int.max
                let chapterGroups = Dictionary(grouping: bookVerses, by: \.chapter)
                let chapters = chapterGroups
                    .map { chapterNumber, chapterVerses -> BibleChapter in
                        let verses = chapterVerses
                            .sorted { $0.verse < $1.verse }
                            .map { BibleVerse(number: $0.verse, text: $0.text) }

                        return BibleChapter(number: chapterNumber, verses: verses)
                    }
                    .sorted { $0.number < $1.number }

                chaptersByBookName[bookName] = chapters
                versesByBookAndChapter[bookName] = Dictionary(
                    uniqueKeysWithValues: chapters.map { chapter in
                        (chapter.number, chapter.verses)
                    }
                )

                return BibleBook(
                    name: bookName,
                    abbreviation: abbreviation(for: bookName),
                    testament: bookNumber <= 39 ? .old : .new,
                    chapters: chapters
                )
            }
            .sorted { lhs, rhs in
                let lhsBook = bookOrderByName[lhs.name] ?? Int.max
                let rhsBook = bookOrderByName[rhs.name] ?? Int.max

                if lhsBook == rhsBook {
                    return lhs.name < rhs.name
                }

                return lhsBook < rhsBook
            }

        return GroupedBible(
            books: books,
            chaptersByBookName: chaptersByBookName,
            versesByBookAndChapter: versesByBookAndChapter
        )
    }

    static func abbreviation(for bookName: String) -> String {
        bookName
            .split(separator: " ")
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()
    }
}

private struct KJVRoot: Decodable {
    let metadata: KJVMetadata
    let verses: [KJVVerseDTO]
}

private struct KJVMetadata: Decodable {
    let name: String?
    let shortname: String?
    let module: String?
}

private struct KJVVerseDTO: Decodable {
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

enum LocalBibleServiceError: LocalizedError {
    case missingResource(String)

    var errorDescription: String? {
        switch self {
        case .missingResource(let resourceName):
            return "\(resourceName) was not found in the app bundle."
        }
    }
}
