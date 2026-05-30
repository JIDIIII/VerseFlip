//
//  ESVBibleAPIService.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

final class ESVBibleAPIService: BibleVersionServiceProtocol {
    let version = BibleVersion.esv

    private let apiKey: String?

    init(apiKey: String? = nil) {
        let trimmedKey = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.apiKey = trimmedKey?.isEmpty == false ? trimmedKey : nil
    }

    var availability: BibleServiceAvailability {
        guard apiKey != nil else {
            return .unavailable(reason: "ESV requires an official API key before verses can be loaded.")
        }

        return .unavailable(reason: "ESV official API integration is not implemented yet.")
    }

    func getBooks() -> [BibleBook] {
        []
    }

    func getChapters(book: BibleBook) -> [BibleChapter] {
        []
    }

    func getVerses(book: BibleBook, chapter: Int) -> [BibleVerse] {
        []
    }
}
