//
//  FlipCardView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct FlipCardView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let card: VerseCard
    let isShowingVerse: Bool
    var maxCardHeight: CGFloat = 460
    let onTap: () -> Void

    var body: some View {
        ZStack {
            cardFace(isBack: false)
                .opacity(isShowingVerse ? 0 : 1)
                .rotation3DEffect(
                    .degrees(reduceMotion ? 0 : (isShowingVerse ? 180 : 0)),
                    axis: (x: 0, y: 1, z: 0)
                )

            cardFace(isBack: true)
                .opacity(isShowingVerse ? 1 : 0)
                .rotation3DEffect(
                    .degrees(reduceMotion ? 0 : (isShowingVerse ? 0 : -180)),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .frame(maxWidth: .infinity)
        .contentShape(RoundedRectangle(cornerRadius: VFSpacing.cardCornerRadius, style: .continuous))
        .onTapGesture(perform: onTap)
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: isShowingVerse)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(isShowingVerse ? "Verse side" : "Reference side")
        .accessibilityValue(isShowingVerse ? card.verseText : card.reference)
        .accessibilityHint(isShowingVerse ? "Tap to show reference" : "Tap to reveal verse")
    }

    private func cardFace(isBack: Bool) -> some View {
        VFCard(padding: VFSpacing.large) {
            VStack(spacing: VFSpacing.medium) {
                Text(isBack ? "BACK" : "FRONT")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(VFColors.primaryNavy)
                    .padding(.horizontal, VFSpacing.large)
                    .padding(.vertical, VFSpacing.small)
                    .background(VFColors.warmCream)
                    .clipShape(Capsule())

                Spacer(minLength: 0)

                if isBack {
                    backContent
                } else {
                    frontContent
                }

                Spacer(minLength: 0)

                Rectangle()
                    .fill(VFColors.softGold)
                    .frame(width: 48, height: 1.5)

                Label(isBack ? "Tap to show reference" : "Tap to reveal verse", systemImage: "hand.tap")
                    .font(VFFonts.footnote)
                    .foregroundStyle(VFColors.primaryNavy)
            }
            .frame(maxWidth: .infinity)
            .frame(height: maxCardHeight)
        }
    }

    private var frontContent: some View {
        VStack(spacing: VFSpacing.large) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 46, weight: .semibold))
                .foregroundStyle(VFColors.softGold)
                .frame(width: 86, height: 86)
                .background(VFColors.warmCream)
                .clipShape(Circle())

            Text(card.reference)
                .font(.system(size: referenceTextSize, weight: .bold, design: .serif))
                .foregroundStyle(VFColors.primaryNavy)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .minimumScaleFactor(0.72)

            Text(card.bibleVersion.rawValue)
                .font(VFFonts.callout)
                .foregroundStyle(VFColors.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private var backContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: VFSpacing.small) {
                Text("\"")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundStyle(VFColors.softGold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(card.verseText)
                    .font(.system(size: verseTextSize(for: card.verseText), weight: .regular, design: .serif))
                    .foregroundStyle(VFColors.primaryNavy)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(5)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.75)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }

    private var referenceTextSize: CGFloat {
        card.reference.count > 30 ? 28 : 32
    }

    private func verseTextSize(for text: String) -> CGFloat {
        let wordCount = text.split { $0.isWhitespace || $0.isNewline }.count

        switch wordCount {
        case 0...30:
            return 30
        case 31...60:
            return 24
        case 61...100:
            return 20
        default:
            return 17
        }
    }
}

struct FlipCardView_Previews: PreviewProvider {
    static var previews: some View {
        FlipCardView(
            card: VerseCard(
                verseText: "For God so loved the world that he gave his only begotten Son, that whoever believeth in him should not perish, but have everlasting life.",
                reference: "John 3:16 KJV",
                book: "John",
                chapter: 3,
                verseStart: 16
            ),
            isShowingVerse: false
        ) {}
        .padding()
        .background(VFColors.warmCream)
    }
}
