//
//  BibleVerse.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

struct BibleVerse: Identifiable, Codable, Hashable {
    let id: UUID
    var number: Int
    var text: String

    init(id: UUID = UUID(), number: Int, text: String) {
        self.id = id
        self.number = number
        self.text = text
    }
}
