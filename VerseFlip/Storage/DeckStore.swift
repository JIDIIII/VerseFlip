//
//  DeckStore.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

final class DeckStore {
    private let fileURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private(set) var decks: [Deck]

    init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? Self.defaultFileURL
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        decks = Self.loadDecks(from: self.fileURL, decoder: decoder)
        ensureDefaultDeck()
    }

    @discardableResult
    func createDeck(name: String, iconName: String = "book.closed.fill") throws -> Deck {
        let deck = Deck(name: name, iconName: iconName)
        decks.append(deck)
        try save()
        return deck
    }

    func upsert(_ deck: Deck) throws {
        if let index = decks.firstIndex(where: { $0.id == deck.id }) {
            decks[index] = deck
        } else {
            decks.append(deck)
        }

        try save()
    }

    func deleteDeck(id: UUID) throws {
        decks.removeAll { $0.id == id && $0.id != Deck.defaultDeck.id }
        try save()
    }

    func reload() {
        decks = Self.loadDecks(from: fileURL, decoder: decoder)
        ensureDefaultDeck()
    }

    func save() throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let data = try encoder.encode(decks)
        try data.write(to: fileURL, options: [.atomic])
    }

    private func ensureDefaultDeck() {
        guard decks.contains(where: { $0.id == Deck.defaultDeck.id }) == false else {
            return
        }

        decks.insert(Deck.defaultDeck, at: 0)
        try? save()
    }

    private static func loadDecks(from fileURL: URL, decoder: JSONDecoder) -> [Deck] {
        guard
            FileManager.default.fileExists(atPath: fileURL.path),
            let data = try? Data(contentsOf: fileURL),
            let decks = try? decoder.decode([Deck].self, from: data)
        else {
            return []
        }

        return decks
    }

    private static var defaultFileURL: URL {
        FileManager.default.applicationSupportDirectory
            .appendingPathComponent("VerseFlip", isDirectory: true)
            .appendingPathComponent("decks.json")
    }
}

private extension FileManager {
    var applicationSupportDirectory: URL {
        urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }
}
