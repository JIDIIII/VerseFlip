//
//  VerseCardStore.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

final class VerseCardStore {
    private let fileURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private(set) var cards: [VerseCard]

    init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? Self.defaultFileURL
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        cards = Self.loadCards(from: self.fileURL, decoder: decoder)
    }

    func add(_ card: VerseCard) throws {
        cards.append(card)
        try save()
    }

    func upsert(_ card: VerseCard) throws {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
        } else {
            cards.append(card)
        }

        try save()
    }

    func deleteCard(id: UUID) throws {
        cards.removeAll { $0.id == id }
        try save()
    }

    func deleteCards(in deckId: UUID) throws {
        cards.removeAll { $0.deckId == deckId }
        try save()
    }

    func cards(in deckId: UUID) -> [VerseCard] {
        cards.filter { $0.deckId == deckId }
    }

    func reload() {
        cards = Self.loadCards(from: fileURL, decoder: decoder)
    }

    func save() throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let data = try encoder.encode(cards)
        try data.write(to: fileURL, options: [.atomic])
    }

    private static func loadCards(from fileURL: URL, decoder: JSONDecoder) -> [VerseCard] {
        guard
            FileManager.default.fileExists(atPath: fileURL.path),
            let data = try? Data(contentsOf: fileURL),
            let cards = try? decoder.decode([VerseCard].self, from: data)
        else {
            return []
        }

        return cards
    }

    private static var defaultFileURL: URL {
        FileManager.default.applicationSupportDirectory
            .appendingPathComponent("VerseFlip", isDirectory: true)
            .appendingPathComponent("verse_cards.json")
    }
}

private extension FileManager {
    var applicationSupportDirectory: URL {
        urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }
}
