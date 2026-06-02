//
//  BibleServiceFactory.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

enum BibleServiceFactory {
    static func makeDefaultService(bundle: Bundle = .main) -> BibleServiceProtocol {
        #if DEBUG
        print("ESV API key loaded:", AppSecrets.isESVAPIKeyConfigured(in: bundle))
        print("ESV API key length:", AppSecrets.esvAPIKey(in: bundle).count)
        print("NIV API key loaded:", AppSecrets.isNIVAPIKeyConfigured(in: bundle))
        print("NIV API key length:", AppSecrets.nivAPIKey(in: bundle).count)
        #endif

        let localBibleService = LocalBibleService(bundle: bundle)

        return VersionedBibleService(
            services: [
                localBibleService,
                ESVBibleAPIService(
                    apiKey: AppSecrets.esvAPIKey(in: bundle),
                    referenceCatalog: localBibleService
                ),
                NIVBibleAPIService(
                    apiKey: AppSecrets.nivAPIKey(in: bundle),
                    referenceCatalog: localBibleService
                )
            ]
        )
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

    func fetchPassage(version: BibleVersion, reference: String) async throws -> VerseCardDraft {
        guard let service = availableService(for: version) else {
            let reason = getAvailability(for: version).reason ?? "\(version.rawValue) is unavailable."
            throw BiblePassageFetchError.unavailable(reason: reason)
        }

        guard let passageService = service as? BiblePassageFetching else {
            throw BiblePassageFetchError.unavailable(reason: "\(version.rawValue) passage fetching is not available.")
        }

        return try await passageService.fetchPassage(reference: reference)
    }

    private func availableService(for version: BibleVersion) -> BibleVersionServiceProtocol? {
        guard let service = servicesByVersion[version],
              service.availability.isAvailable else {
            return nil
        }

        return service
    }
}
