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

    var copyrightNotice: String? {
        switch self {
        case .esv:
            return "ESV® Text Edition: 2016. Copyright © 2001 by Crossway Bibles."
        case .niv:
            return "Holy Bible, New International Version® NIV® Copyright © 1973, 1978, 1984, 2011 by Biblica, Inc. Used by permission. All rights reserved worldwide."
        case .kjv:
            return nil
        }
    }
}
