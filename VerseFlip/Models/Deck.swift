//
//  Deck.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

struct Deck: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var iconName: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String = "book.closed.fill",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.createdAt = createdAt
    }
}

extension Deck {
    static let defaultDeck = Deck(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
        name: "My Verses",
        iconName: "book.closed.fill",
        createdAt: Date(timeIntervalSince1970: 0)
    )
}
