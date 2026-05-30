//
//  ProgressCardView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct ProgressCardView: View {
    let versesSaved: Int
    let dueForReview: Int
    let memorized: Int
    let learning: Int
    let reviewing: Int
    let difficult: Int

    init(
        versesSaved: Int,
        dueForReview: Int,
        memorized: Int,
        learning: Int = 0,
        reviewing: Int = 0,
        difficult: Int = 0
    ) {
        self.versesSaved = versesSaved
        self.dueForReview = dueForReview
        self.memorized = memorized
        self.learning = learning
        self.reviewing = reviewing
        self.difficult = difficult
    }

    var body: some View {
        VFCard(padding: VFSpacing.large) {
            VStack(alignment: .leading, spacing: VFSpacing.xLarge) {
                Text("Today's Progress")
                    .font(.system(size: 21, weight: .bold, design: .serif))
                    .foregroundStyle(VFColors.primaryNavy)

                HStack(spacing: 0) {
                    ProgressMetricView(
                        systemImage: "bookmark",
                        count: versesSaved,
                        label: "verses saved",
                        tint: VFColors.softGold,
                        background: VFColors.warmCream
                    )

                    progressDivider

                    ProgressMetricView(
                        systemImage: "arrow.clockwise",
                        count: dueForReview,
                        label: "due for review",
                        tint: VFColors.primaryNavy,
                        background: VFColors.learningBlue
                    )

                    progressDivider

                    ProgressMetricView(
                        systemImage: "crown",
                        count: memorized,
                        label: "memorized",
                        tint: VFColors.softGold,
                        background: VFColors.successGreen
                    )
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Today's Progress")
                .accessibilityValue("\(versesSaved) verses saved, \(dueForReview) due for review, \(memorized) memorized, \(learning) learning, \(reviewing) reviewing, \(difficult) difficult")
            }
        }
    }

    private var progressDivider: some View {
        Rectangle()
            .fill(VFColors.softBorder)
            .frame(width: 1, height: 72)
            .padding(.horizontal, VFSpacing.small)
    }
}

private struct ProgressMetricView: View {
    let systemImage: String
    let count: Int
    let label: String
    let tint: Color
    let background: Color

    var body: some View {
        VStack(spacing: VFSpacing.small) {
            Image(systemName: systemImage)
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 52, height: 52)
                .background(background)
                .clipShape(Circle())

            Text("\(count)")
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundStyle(VFColors.primaryNavy)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(VFColors.textMuted)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProgressCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCardView(versesSaved: 12, dueForReview: 5, memorized: 3)
            .padding()
            .background(VFColors.warmCream)
    }
}
