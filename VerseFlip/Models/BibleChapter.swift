//
//  BibleChapter.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

struct BibleChapter: Identifiable, Codable, Hashable {
    let id: UUID
    var number: Int
    var verses: [BibleVerse]

    init(id: UUID = UUID(), number: Int, verses: [BibleVerse] = []) {
        self.id = id
        self.number = number
        self.verses = verses
    }
}
