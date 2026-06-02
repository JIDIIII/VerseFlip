//
//  ESVBibleAPIService.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

final class ESVBibleAPIService: BibleVersionServiceProtocol, BiblePassageFetching {
    let version = BibleVersion.esv

    private static let missingAPIKeyMessage = "ESV API key is missing. Add it to Secrets.xcconfig to enable ESV."

    private let endpoint = URL(string: "https://api.esv.org/v3/passage/text/")!
    private let apiKey: String?
    private let urlSession: URLSession
    private let referenceCatalog: BibleVersionServiceProtocol

    init(
        apiKey: String? = AppSecrets.esvAPIKey,
        urlSession: URLSession = .shared,
        referenceCatalog: BibleVersionServiceProtocol = LocalBibleService()
    ) {
        let trimmedKey = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.apiKey = trimmedKey.map(AppSecrets.isESVAPIKeyConfigured) == true ? trimmedKey : nil
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

    private var authorizationHeaderValue: String? {
        guard let apiKey else {
            return nil
        }

        return "Token \(apiKey)"
    }

    private func applyAuthorizationHeader(to request: inout URLRequest) {
        guard let authorizationHeaderValue else {
            return
        }

        request.setValue(authorizationHeaderValue, forHTTPHeaderField: "Authorization")
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
        guard availability.isAvailable else {
            let reason = availability.reason ?? "ESV is unavailable right now."
            throw BiblePassageFetchError.unavailable(reason: reason)
        }

        let trimmedReference = reference.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedReference.isEmpty == false else {
            throw ESVBibleAPIServiceError.emptyReference
        }

        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "q", value: trimmedReference),
            URLQueryItem(name: "include-passage-references", value: "false"),
            URLQueryItem(name: "include-verse-numbers", value: "false"),
            URLQueryItem(name: "include-footnotes", value: "false"),
            URLQueryItem(name: "include-footnote-body", value: "false"),
            URLQueryItem(name: "include-headings", value: "false"),
            URLQueryItem(name: "include-short-copyright", value: "true"),
            URLQueryItem(name: "indent-paragraphs", value: "0"),
            URLQueryItem(name: "include-selahs", value: "false")
        ]

        guard let url = components?.url else {
            throw ESVBibleAPIServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        applyAuthorizationHeader(to: &request)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw ESVBibleAPIServiceError.network
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ESVBibleAPIServiceError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401, 403:
            throw ESVBibleAPIServiceError.unauthorized
        case 404:
            throw ESVBibleAPIServiceError.notFound
        default:
            throw ESVBibleAPIServiceError.requestFailed(statusCode: httpResponse.statusCode)
        }

        let esvResponse: ESVPassageResponse
        do {
            esvResponse = try JSONDecoder().decode(ESVPassageResponse.self, from: data)
        } catch {
            throw ESVBibleAPIServiceError.invalidResponse
        }

        let passageText = cleanPassageText(esvResponse.passages.joined(separator: "\n"))

        guard passageText.isEmpty == false else {
            throw ESVBibleAPIServiceError.notFound
        }

        let canonicalReference = esvResponse.passageMeta?.first?.canonical
            ?? esvResponse.canonical
            ?? esvResponse.query
            ?? trimmedReference

        return VerseCardDraft(
            verseText: passageText,
            reference: canonicalReference,
            bibleVersion: .esv
        )
    }

    private func cleanPassageText(_ text: String) -> String {
        var cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        while cleanedText.contains("\n\n") {
            cleanedText = cleanedText.replacingOccurrences(of: "\n\n", with: "\n")
        }

        return cleanedText
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

private struct ESVPassageResponse: Decodable {
    let query: String?
    let canonical: String?
    let passages: [String]
    let passageMeta: [ESVPassageMeta]?

    enum CodingKeys: String, CodingKey {
        case query
        case canonical
        case passages
        case passageMeta = "passage_meta"
    }
}

private struct ESVPassageMeta: Decodable {
    let canonical: String?
}

enum ESVBibleAPIServiceError: LocalizedError {
    case emptyReference
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case unauthorized
    case notFound
    case network
    case requestFailed(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .emptyReference:
            return "Please enter a Bible reference."
        case .missingAPIKey:
            return "ESV API key is missing. Add it to Secrets.xcconfig to enable ESV."
        case .invalidURL:
            return "Could not prepare the ESV request."
        case .invalidResponse:
            return "Could not read the ESV response."
        case .unauthorized:
            return "ESV API key is missing or invalid."
        case .notFound:
            return "Could not fetch this passage. Check the reference and try again."
        case .network:
            return "Network error. Please check your connection."
        case .requestFailed:
            return "Could not fetch this passage. Check the reference and try again."
        }
    }
}
