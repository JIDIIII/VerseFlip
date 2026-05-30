//
//  BibleVersion.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

enum BibleVersion: String, Codable, CaseIterable, Identifiable, Hashable {
    case kjv = "KJV"
    case esv = "ESV"
    case niv = "NIV"

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .kjv:
            return "King James Version"
        case .esv:
            return "English Standard Version"
        case .niv:
            return "New International Version"
        }
    }
}
