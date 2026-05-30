//
//  VFSectionHeader.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct VFSectionHeader: View {
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: VFSpacing.medium) {
            VStack(alignment: .leading, spacing: VFSpacing.xSmall) {
                Text(title)
                    .font(VFFonts.title2)
                    .foregroundStyle(VFColors.primaryNavy)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(VFFonts.callout)
                        .foregroundStyle(VFColors.textMuted)
                }
            }

            Spacer(minLength: VFSpacing.medium)

            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .font(VFFonts.footnote)
                    .foregroundStyle(VFColors.softGold)
            }
        }
    }
}

struct VFSectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: VFSpacing.xLarge) {
            VFSectionHeader(title: "Your Library", subtitle: "12 saved cards")
            VFSectionHeader(title: "Recent Decks", actionTitle: "See All") {}
        }
        .padding()
        .background(VFColors.warmCream)
    }
}
