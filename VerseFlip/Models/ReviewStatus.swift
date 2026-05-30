//
//  ReviewStatus.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import Foundation

enum ReviewStatus: String, Codable, CaseIterable, Identifiable, Hashable {
    case learning
    case reviewing
    case memorized
    case difficult

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .learning:
            return "Learning"
        case .reviewing:
            return "Reviewing"
        case .memorized:
            return "Memorized"
        case .difficult:
            return "Difficult"
        }
    }
}
