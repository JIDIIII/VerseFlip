//
//  VFColors.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

enum VFColors {
    static let primaryNavy = Color(hex: 0x17223B)
    static let warmCream = Color(hex: 0xF8F4EC)
    static let softGold = Color(hex: 0xD6A84F)
    static let textDark = Color(hex: 0x1F2937)
    static let textMuted = Color(hex: 0x6B7280)
    static let cardBackground = Color(hex: 0xFFFFFF)
    static let softBorder = Color(hex: 0xE7E1D6)
    static let successGreen = Color(hex: 0xDDEAD8)
    static let learningBlue = Color(hex: 0xE8EEF8)
    static let dangerRed = Color(hex: 0xC75C48)
    static let successText = Color(hex: 0x3F6F37)
    static let splashHighlight = Color(hex: 0xFFFFFF)

    static let shadow = Color(hex: 0x000000, alpha: 0.08)
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
