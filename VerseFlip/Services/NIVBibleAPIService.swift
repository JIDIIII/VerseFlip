//
//  NIVBibleAPIService.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

final class NIVBibleAPIService: BibleVersionServiceProtocol {
    let version = BibleVersion.niv

    private let apiKey: String?

    init(apiKey: String? = nil) {
        let trimmedKey = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.apiKey = trimmedKey?.isEmpty == false ? trimmedKey : nil
    }

    var availability: BibleServiceAvailability {
        guard apiKey != nil else {
            return .unavailable(reason: "NIV requires an official licensed API key before verses can be loaded.")
        }

        return .unavailable(reason: "NIV official licensed API integration is not implemented yet.")
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
