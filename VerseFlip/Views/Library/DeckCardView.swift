//
//  DeckCardView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct DeckCardView: View {
    let deckName: String
    let iconName: String
    let verseCount: Int

    var body: some View {
        VFCard(padding: VFSpacing.large) {
            VStack(spacing: VFSpacing.medium) {
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 78, height: 78)

                    Image(systemName: iconName)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(iconForegroundColor)
                }
                .overlay(alignment: .bottomTrailing) {
                    if isDefaultDeck {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundStyle(VFColors.softGold)
                            .background(Circle().fill(VFColors.cardBackground))
                            .offset(x: 4, y: 4)
                    }
                }

                VStack(spacing: VFSpacing.xSmall) {
                    Text(deckName)
                        .font(.system(size: 19, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)

                    Text(verseCount == 1 ? "1 verse" : "\(verseCount) verses")
                        .font(VFFonts.body)
                        .foregroundStyle(VFColors.textMuted)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 128)
        }
    }

    private var isDefaultDeck: Bool {
        deckName == "Default Deck"
    }

    private var iconForegroundColor: Color {
        isDefaultDeck ? VFColors.primaryNavy : VFColors.softGold
    }

    private var iconBackgroundColor: Color {
        isDefaultDeck ? VFColors.warmCream : VFColors.warmCream.opacity(0.82)
    }
}

struct DeckCardView_Previews: PreviewProvider {
    static var previews: some View {
        DeckCardView(deckName: "Default Deck", iconName: "book.closed.fill", verseCount: 12)
            .padding()
            .background(VFColors.warmCream)
    }
}
