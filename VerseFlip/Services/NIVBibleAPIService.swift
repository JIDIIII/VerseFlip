//
//  NIVBibleAPIService.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

final class NIVBibleAPIService: BibleVersionServiceProtocol, BiblePassageFetching {
    let version = BibleVersion.niv

    private static let missingAPIKeyMessage = "NIV API key is missing. Add it to Secrets.xcconfig."

    private let endpoint = URL(string: "https://niv-bible.p.rapidapi.com/row")!
    private let rapidAPIHost = "niv-bible.p.rapidapi.com"
    private let apiKey: String?
    private let urlSession: URLSession
    private let referenceCatalog: BibleVersionServiceProtocol

    init(
        apiKey: String? = AppSecrets.nivAPIKey,
        urlSession: URLSession = .shared,
        referenceCatalog: BibleVersionServiceProtocol = LocalBibleService()
    ) {
        let trimmedKey = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.apiKey = trimmedKey.map(AppSecrets.isNIVAPIKeyConfigured) == true ? trimmedKey : nil
        self.urlSession = urlSession
        self.referenceCatalog = referenceCatalog
    }

    var availability: BibleServiceAvailability {
        guard apiKey != nil else {
            return .unavailable(reason: Self.missingAPIKeyMessage)
        }

        guard referenceCatalog.availability.isAvailable else {
            let reason = referenceCatalog.availability.reason ?? "Bible reference data is unavailable right now."
            return .unavailable(reason: reason)
        }

        return .available
    }

    func getBooks() -> [BibleBook] {
        guard availability.isAvailable else {
            return []
        }

        return referenceCatalog.getBooks().map(textlessBook)
    }

    func getChapters(book: BibleBook) -> [BibleChapter] {
        guard availability.isAvailable else {
            return []
        }

        return referenceCatalog.getChapters(book: book).map(textlessChapter)
    }

    func getVerses(book: BibleBook, chapter: Int) -> [BibleVerse] {
        guard availability.isAvailable else {
            return []
        }

        return referenceCatalog
            .getVerses(book: book, chapter: chapter)
            .map(textlessVerse)
    }

    func fetchPassage(reference: String) async throws -> VerseCardDraft {
        guard apiKey != nil else {
            throw NIVBibleAPIError.missingAPIKey
        }

        guard referenceCatalog.availability.isAvailable else {
            let reason = referenceCatalog.availability.reason ?? "Bible reference data is unavailable right now."
            throw BiblePassageFetchError.unavailable(reason: reason)
        }

        let parsedReference = try NIVReferenceParser.parse(reference)
        let verseNumbers = parsedReference.verseNumbers
        let fetchedVerses = try await fetchVerses(
            book: parsedReference.book,
            chapter: parsedReference.chapter,
            verses: verseNumbers
        )

        let passageText = fetchedVerses
            .map(\.text)
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard passageText.isEmpty == false else {
            throw NIVBibleAPIError.emptyResponse
        }

        let firstVerse = fetchedVerses.first
        let bookName = firstVerse?.bookName ?? parsedReference.book
        let chapter = firstVerse?.chapter ?? parsedReference.chapter
        let referenceSuffix = verseNumbers.count == 1
            ? "\(verseNumbers[0])"
            : "\(verseNumbers[0])-\(verseNumbers[verseNumbers.count - 1])"

        return VerseCardDraft(
            verseText: passageText,
            reference: "\(bookName) \(chapter):\(referenceSuffix)",
            bibleVersion: .niv
        )
    }

    func fetchVerse(book: String, chapter: Int, verse: Int) async throws -> BibleVerse {
        let fetchedVerse = try await fetchVerseRow(book: book, chapter: chapter, verse: verse)
        return BibleVerse(number: fetchedVerse.verse, text: fetchedVerse.text)
    }

    private func fetchVerses(book: String, chapter: Int, verses: [Int]) async throws -> [NIVFetchedVerse] {
        var fetchedVerses: [NIVFetchedVerse] = []

        for verse in verses {
            let fetchedVerse = try await fetchVerseRow(book: book, chapter: chapter, verse: verse)
            fetchedVerses.append(fetchedVerse)
        }

        return fetchedVerses
    }

    private func fetchVerseRow(book: String, chapter: Int, verse: Int) async throws -> NIVFetchedVerse {
        let request = try makeRequest(book: book, chapter: chapter, verse: verse)

        #if DEBUG
        print("NIV API key loaded:", AppSecrets.isNIVAPIKeyConfigured)
        print("NIV API key length:", AppSecrets.nivAPIKey.count)
        print("NIV request URL:", request.url?.absoluteString ?? "nil")
        print("NIV request host header:", request.value(forHTTPHeaderField: "x-rapidapi-host") ?? "missing")
        print("NIV has rapidapi key header:", request.value(forHTTPHeaderField: "x-rapidapi-key")?.isEmpty == false)
        #endif

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw NIVBibleAPIError.networkError(error.localizedDescription)
        }

        #if DEBUG
        if let httpResponse = response as? HTTPURLResponse {
            print("NIV status code:", httpResponse.statusCode)
        }
        if let body = String(data: data, encoding: .utf8) {
            print("NIV response body preview:", String(body.prefix(500)))
        }
        #endif

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NIVBibleAPIError.networkError("The NIV API did not return an HTTP response.")
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw NIVBibleAPIError.unauthorized
        case 403:
            throw NIVBibleAPIError.forbidden
        case 404:
            throw NIVBibleAPIError.notFound
        case 429:
            throw NIVBibleAPIError.rateLimited
        case 500...599:
            throw NIVBibleAPIError.serverError(httpResponse.statusCode)
        default:
            throw NIVBibleAPIError.serverError(httpResponse.statusCode)
        }

        let apiResponse: NIVRowResponse
        do {
            apiResponse = try JSONDecoder().decode(NIVRowResponse.self, from: data)
        } catch {
            throw NIVBibleAPIError.decodingFailed
        }

        let verseText = (apiResponse.text.first ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard verseText.isEmpty == false else {
            throw NIVBibleAPIError.emptyResponse
        }

        return NIVFetchedVerse(
            bookName: apiResponse.book.first ?? book,
            chapter: apiResponse.chapter.first ?? chapter,
            verse: apiResponse.verse.first ?? verse,
            text: verseText
        )
    }

    private func makeRequest(book: String, chapter: Int, verse: Int) throws -> URLRequest {
        guard let apiKey else {
            throw NIVBibleAPIError.missingAPIKey
        }

        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "Book", value: book),
            URLQueryItem(name: "Chapter", value: String(chapter)),
            URLQueryItem(name: "Verse", value: String(verse))
        ]

        guard let url = components?.url else {
            throw NIVBibleAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(rapidAPIHost, forHTTPHeaderField: "x-rapidapi-host")
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        return request
    }

    private func textlessBook(_ book: BibleBook) -> BibleBook {
        BibleBook(
            id: book.id,
            name: book.name,
            abbreviation: book.abbreviation,
            testament: book.testament,
            chapters: book.chapters.map(textlessChapter)
        )
    }

    private func textlessChapter(_ chapter: BibleChapter) -> BibleChapter {
        BibleChapter(
            id: chapter.id,
            number: chapter.number,
            verses: chapter.verses.map(textlessVerse)
        )
    }

    private func textlessVerse(_ verse: BibleVerse) -> BibleVerse {
        BibleVerse(id: verse.id, number: verse.number, text: "")
    }
}

private struct NIVFetchedVerse {
    let bookName: String
    let chapter: Int
    let verse: Int
    let text: String
}

private struct NIVRowResponse: Decodable {
    let book: [String]
    let chapter: [Int]
    let text: [String]
    let verse: [Int]

    enum CodingKeys: String, CodingKey {
        case book = "Book"
        case chapter = "Chapter"
        case text = "Text"
        case verse = "Verse"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        book = try container.decodeOneOrMany(String.self, forKey: .book)
        chapter = try container.decodeOneOrMany(Int.self, forKey: .chapter)
        text = try container.decodeOneOrMany(String.self, forKey: .text)
        verse = try container.decodeOneOrMany(Int.self, forKey: .verse)
    }
}

private extension KeyedDecodingContainer {
    func decodeOneOrMany<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> [T] {
        if let array = try? decode([T].self, forKey: key) {
            return array
        }

        if let dictionary = try? decode([String: T].self, forKey: key) {
            return dictionary
                .sorted { lhs, rhs in
                    let lhsIndex = Int(lhs.key) ?? Int.max
                    let rhsIndex = Int(rhs.key) ?? Int.max
                    return lhsIndex == rhsIndex ? lhs.key < rhs.key : lhsIndex < rhsIndex
                }
                .map(\.value)
        }

        return [try decode(T.self, forKey: key)]
    }
}

private struct NIVParsedReference {
    let book: String
    let chapter: Int
    let verseStart: Int
    let verseEnd: Int?

    var verseNumbers: [Int] {
        let end = verseEnd ?? verseStart
        return Array(verseStart...end)
    }
}

private enum NIVReferenceParser {
    private static let booksByNormalizedName: [String: String] = {
        let entries: [(String, [String])] = [
            ("Genesis", ["Gen"]),
            ("Exodus", ["Exod", "Exo"]),
            ("Leviticus", ["Lev"]),
            ("Numbers", ["Num"]),
            ("Deuteronomy", ["Deut", "Deu"]),
            ("Joshua", ["Josh", "Jos"]),
            ("Judges", ["Judg", "Jdg"]),
            ("Ruth", ["Rth"]),
            ("1 Samuel", ["1 Sam", "1Samuel", "First Samuel"]),
            ("2 Samuel", ["2 Sam", "2Samuel", "Second Samuel"]),
            ("1 Kings", ["1 Kgs", "1Kings", "First Kings"]),
            ("2 Kings", ["2 Kgs", "2Kings", "Second Kings"]),
            ("1 Chronicles", ["1 Chr", "1Chronicles", "First Chronicles"]),
            ("2 Chronicles", ["2 Chr", "2Chronicles", "Second Chronicles"]),
            ("Ezra", []),
            ("Nehemiah", ["Neh"]),
            ("Esther", ["Esth", "Est"]),
            ("Job", []),
            ("Psalms", ["Psalm", "Ps", "Psa"]),
            ("Proverbs", ["Prov", "Pro"]),
            ("Ecclesiastes", ["Eccl", "Ecc"]),
            ("Song of Solomon", ["Song of Songs", "Song", "Sng", "Canticles"]),
            ("Isaiah", ["Isa"]),
            ("Jeremiah", ["Jer"]),
            ("Lamentations", ["Lam"]),
            ("Ezekiel", ["Ezek", "Ezk"]),
            ("Daniel", ["Dan"]),
            ("Hosea", ["Hos"]),
            ("Joel", []),
            ("Amos", []),
            ("Obadiah", ["Obad", "Oba"]),
            ("Jonah", ["Jon"]),
            ("Micah", ["Mic"]),
            ("Nahum", ["Nah", "Nam"]),
            ("Habakkuk", ["Hab"]),
            ("Zephaniah", ["Zeph", "Zep"]),
            ("Haggai", ["Hag"]),
            ("Zechariah", ["Zech", "Zec"]),
            ("Malachi", ["Mal"]),
            ("Matthew", ["Matt", "Mt"]),
            ("Mark", ["Mrk", "Mk"]),
            ("Luke", ["Luk", "Lk"]),
            ("John", ["Jn", "Jhn"]),
            ("Acts", ["Act"]),
            ("Romans", ["Rom"]),
            ("1 Corinthians", ["1 Cor", "1Corinthians", "First Corinthians"]),
            ("2 Corinthians", ["2 Cor", "2Corinthians", "Second Corinthians"]),
            ("Galatians", ["Gal"]),
            ("Ephesians", ["Eph"]),
            ("Philippians", ["Phil", "Php"]),
            ("Colossians", ["Col"]),
            ("1 Thessalonians", ["1 Thess", "1Thessalonians", "First Thessalonians"]),
            ("2 Thessalonians", ["2 Thess", "2Thessalonians", "Second Thessalonians"]),
            ("1 Timothy", ["1 Tim", "1Timothy", "First Timothy"]),
            ("2 Timothy", ["2 Tim", "2Timothy", "Second Timothy"]),
            ("Titus", []),
            ("Philemon", ["Phlm", "Phm"]),
            ("Hebrews", ["Heb"]),
            ("James", ["Jas"]),
            ("1 Peter", ["1 Pet", "1Peter", "First Peter"]),
            ("2 Peter", ["2 Pet", "2Peter", "Second Peter"]),
            ("1 John", ["1 Jn", "1John", "First John"]),
            ("2 John", ["2 Jn", "2John", "Second John"]),
            ("3 John", ["3 Jn", "3John", "Third John"]),
            ("Jude", []),
            ("Revelation", ["Rev"])
        ]

        return entries.reduce(into: [:]) { result, entry in
            let (name, aliases) = entry
            ([name] + aliases).forEach { result[normalizeBookName($0)] = name }
        }
    }()

    static func parse(_ reference: String) throws -> NIVParsedReference {
        let pattern = #"^\s*([1-3]?\s?[A-Za-z]+(?:\s+[A-Za-z]+)*)\s+(\d+):(\d+)(?:\s*[-–]\s*(?:(\d+):)?(\d+))?\s*(?:NIV)?\s*$"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            throw NIVBibleAPIError.invalidReference
        }

        let range = NSRange(reference.startIndex..<reference.endIndex, in: reference)
        guard let match = regex.firstMatch(in: reference, range: range),
              let bookRange = Range(match.range(at: 1), in: reference),
              let chapterRange = Range(match.range(at: 2), in: reference),
              let verseStartRange = Range(match.range(at: 3), in: reference),
              let chapter = Int(reference[chapterRange]),
              let verseStart = Int(reference[verseStartRange]),
              chapter > 0,
              verseStart > 0 else {
            throw NIVBibleAPIError.invalidReference
        }

        let normalizedBookName = normalizeBookName(String(reference[bookRange]))
        guard let book = booksByNormalizedName[normalizedBookName] else {
            throw NIVBibleAPIError.invalidReference
        }

        guard let verseEndRange = Range(match.range(at: 5), in: reference) else {
            return NIVParsedReference(book: book, chapter: chapter, verseStart: verseStart, verseEnd: nil)
        }

        let endChapter: Int
        if let endChapterRange = Range(match.range(at: 4), in: reference),
           let parsedEndChapter = Int(reference[endChapterRange]) {
            endChapter = parsedEndChapter
        } else {
            endChapter = chapter
        }

        guard endChapter == chapter,
              let verseEnd = Int(reference[verseEndRange]),
              verseEnd >= verseStart else {
            throw NIVBibleAPIError.invalidReference
        }

        return NIVParsedReference(book: book, chapter: chapter, verseStart: verseStart, verseEnd: verseEnd)
    }

    private static func normalizeBookName(_ name: String) -> String {
        name
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: #"^\s*first\s+"#, with: "1 ", options: [.regularExpression, .caseInsensitive])
            .replacingOccurrences(of: #"^\s*second\s+"#, with: "2 ", options: [.regularExpression, .caseInsensitive])
            .replacingOccurrences(of: #"^\s*third\s+"#, with: "3 ", options: [.regularExpression, .caseInsensitive])
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    }
}

enum NIVBibleAPIError: LocalizedError {
    case missingAPIKey
    case invalidReference
    case invalidURL
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case serverError(Int)
    case decodingFailed
    case emptyResponse
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "NIV API key is missing. Add it to Secrets.xcconfig."
        case .invalidReference:
            return "Please enter a valid Bible reference like John 3:16."
        case .invalidURL:
            return "Could not build the NIV API request URL."
        case .unauthorized:
            return "NIV API key is invalid or missing from the x-rapidapi-key header."
        case .forbidden:
            return "NIV API key is not authorized for this RapidAPI endpoint. Check your RapidAPI subscription."
        case .notFound:
            return "The requested NIV verse was not found."
        case .rateLimited:
            return "NIV API rate limit reached. Please try again later."
        case .serverError(let code):
            return "NIV API server error: \(code)."
        case .decodingFailed:
            return "NIV response format changed or could not be decoded."
        case .emptyResponse:
            return "The NIV API returned an empty verse."
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
