//
//  BibleServiceFactory.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

enum BibleServiceFactory {
    static func makeDefaultService(bundle: Bundle = .main) -> BibleServiceProtocol {
        VersionedBibleService(
            services: [
                LocalBibleService(bundle: bundle),
                ESVBibleAPIService(apiKey: apiKey(named: "ESV_API_KEY", in: bundle)),
                NIVBibleAPIService(apiKey: apiKey(named: "NIV_API_KEY", in: bundle))
            ]
        )
    }

    private static func apiKey(named key: String, in bundle: Bundle) -> String? {
        guard let value = bundle.object(forInfoDictionaryKey: key) as? String else {
            return nil
        }

        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}

final class VersionedBibleService: BibleServiceProtocol {
    private let servicesByVersion: [BibleVersion: BibleVersionServiceProtocol]

    init(services: [BibleVersionServiceProtocol]) {
        self.servicesByVersion = Dictionary(
            services.map { ($0.version, $0) },
            uniquingKeysWith: { first, _ in first }
        )
    }

    func getAvailableVersions() -> [BibleVersion] {
        BibleVersion.allCases.filter { version in
            getAvailability(for: version).isAvailable
        }
    }

    func getAvailability(for version: BibleVersion) -> BibleServiceAvailability {
        guard let service = servicesByVersion[version] else {
            return .unavailable(reason: "\(version.rawValue) is not configured.")
        }

        return service.availability
    }

    func getBooks(version: BibleVersion) -> [BibleBook] {
        guard let service = availableService(for: version) else {
            return []
        }

        return service.getBooks()
    }

    func getChapters(version: BibleVersion, book: BibleBook) -> [BibleChapter] {
        guard let service = availableService(for: version) else {
            return []
        }

        return service.getChapters(book: book)
    }

    func getVerses(version: BibleVersion, book: BibleBook, chapter: Int) -> [BibleVerse] {
        guard let service = availableService(for: version) else {
            return []
        }

        return service.getVerses(book: book, chapter: chapter)
    }

    func getVerseRange(version: BibleVersion, book: BibleBook, chapter: Int, startVerse: Int, endVerse: Int?) -> [BibleVerse] {
        guard let service = availableService(for: version) else {
            return []
        }

        return service.getVerseRange(book: book, chapter: chapter, startVerse: startVerse, endVerse: endVerse)
    }

    private func availableService(for version: BibleVersion) -> BibleVersionServiceProtocol? {
        guard let service = servicesByVersion[version],
              service.availability.isAvailable else {
            return nil
        }

        return service
    }
}
