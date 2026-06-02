//
//  SavedVerseRowView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct SavedVerseRowView: View {
    let card: VerseCard
    let deckName: String
    var showsDeckName = true
    var onDelete: (() -> Void)?

    var body: some View {
        VFCard(padding: VFSpacing.large) {
            HStack(alignment: .center, spacing: VFSpacing.medium) {
                Text("\"")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundStyle(VFColors.softGold)
                    .frame(width: 32, alignment: .center)
                    .offset(y: -6)

                VStack(alignment: .leading, spacing: VFSpacing.small) {
                    HStack(alignment: .top, spacing: VFSpacing.small) {
                        Text(card.reference)
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundStyle(VFColors.primaryNavy)
                            .lineLimit(2)
                            .minimumScaleFactor(0.86)

                        Spacer(minLength: VFSpacing.small)

                        VFStatusChip(status: VFStatusChipStatus(reviewStatus: card.reviewStatus))
                    }

                    Text(card.verseText)
                        .font(VFFonts.callout)
                        .foregroundStyle(VFColors.textDark)
                        .lineSpacing(3)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    if showsDeckName {
                        Label(deckName, systemImage: "books.vertical")
                            .font(VFFonts.footnote)
                            .foregroundStyle(VFColors.textMuted)
                            .lineLimit(1)
                    }

                    if let notice = card.bibleVersion.copyrightNotice {
                        Text(notice)
                            .font(VFFonts.footnote)
                            .foregroundStyle(VFColors.textMuted)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if let onDelete {
                    Button(role: .destructive, action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(VFColors.dangerRed)
                            .frame(width: 34, height: 34)
                            .background(VFColors.dangerRed.opacity(0.10))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Delete verse")
                }
            }
        }
        .contextMenu {
            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete Verse", systemImage: "trash")
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.reference), \(card.reviewStatus.title)")
        .accessibilityValue(showsDeckName ? "\(deckName). \(card.verseText)" : card.verseText)
    }
}

extension VFStatusChipStatus {
    init(reviewStatus: ReviewStatus) {
        switch reviewStatus {
        case .learning:
            self = .learning
        case .reviewing:
            self = .reviewing
        case .memorized:
            self = .memorized
        case .difficult:
            self = .difficult
        }
    }
}

struct SavedVerseRowView_Previews: PreviewProvider {
    static var previews: some View {
        SavedVerseRowView(
            card: VerseCard(
                verseText: "For God so loved the world that he gave his only begotten Son.",
                reference: "John 3:16 KJV",
                book: "John",
                chapter: 3,
                verseStart: 16,
                reviewStatus: .memorized
            ),
            deckName: "Default Deck"
        )
        .padding()
        .background(VFColors.warmCream)
    }
}
