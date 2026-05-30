//
//  BibleBook.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

struct BibleBook: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var abbreviation: String
    var testament: Testament
    var chapters: [BibleChapter]

    init(
        id: UUID = UUID(),
        name: String,
        abbreviation: String,
        testament: Testament,
        chapters: [BibleChapter] = []
    ) {
        self.id = id
        self.name = name
        self.abbreviation = abbreviation
        self.testament = testament
        self.chapters = chapters
    }
}

enum Testament: String, Codable, CaseIterable, Identifiable, Hashable {
    case old = "Old Testament"
    case new = "New Testament"

    var id: String {
        rawValue
    }
}
