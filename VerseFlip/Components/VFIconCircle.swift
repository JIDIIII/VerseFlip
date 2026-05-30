//
//  VFIconCircle.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct VFIconCircle: View {
    let systemName: String
    var size = VFSpacing.iconCircleSize
    var foregroundColor = VFColors.primaryNavy
    var backgroundColor = VFColors.learningBlue

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(foregroundColor)
            .frame(width: size, height: size)
            .background(backgroundColor)
            .clipShape(Circle())
    }
}

struct VFIconCircle_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            VFIconCircle(systemName: "book.closed.fill")
            VFIconCircle(systemName: "star.fill", foregroundColor: VFColors.softGold, backgroundColor: VFColors.warmCream)
        }
        .padding()
        .background(VFColors.cardBackground)
    }
}
