//
//  ReviewCompleteView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct ReviewCompleteView: View {
    let reviewedCount: Int
    let rememberedCount: Int
    let needPracticeCount: Int
    let onBackToHome: () -> Void
    let onReviewAgain: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: VFSpacing.xLarge) {
                VStack(spacing: VFSpacing.medium) {
                    Text("Review Complete")
                        .font(.system(size: 38, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)
                        .multilineTextAlignment(.center)

                    HStack(spacing: VFSpacing.small) {
                        Rectangle()
                            .fill(VFColors.softGold)
                            .frame(width: 58, height: 1.5)

                        Image(systemName: "sparkle")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(VFColors.softGold)

                        Rectangle()
                            .fill(VFColors.softGold)
                            .frame(width: 58, height: 1.5)
                    }
                }

                celebrationCard

                statsCard

                VStack(spacing: VFSpacing.small) {
                    Text("\"")
                        .font(.system(size: 48, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.softGold)
                        .frame(height: 34)

                    Text("Keep hiding God's Word in your heart.")
                        .font(.system(size: 19, weight: .regular))
                        .foregroundStyle(VFColors.primaryNavy)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: VFSpacing.medium) {
                    VFSecondaryButton(title: "Back to Home", systemImage: "house") {
                        onBackToHome()
                    }

                    VFPrimaryButton(title: "Review Again", systemImage: "play.fill") {
                        onReviewAgain()
                    }
                }
                .padding(.bottom, VFSpacing.xLarge)
            }
            .padding(.horizontal, VFSpacing.xLarge)
            .padding(.top, VFSpacing.large)
        }
    }

    private var celebrationCard: some View {
        VFCard(padding: VFSpacing.xLarge) {
            VStack(spacing: VFSpacing.large) {
                ZStack {
                    Circle()
                        .fill(VFColors.warmCream)
                        .frame(width: 176, height: 176)

                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 78, weight: .semibold))
                        .foregroundStyle(VFColors.primaryNavy)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 54, weight: .bold))
                        .foregroundStyle(VFColors.softGold)
                        .background(Circle().fill(VFColors.cardBackground))
                        .offset(x: 58, y: 56)

                    ForEach(0..<10, id: \.self) { index in
                        SparkleDot(index: index)
                    }
                }

                VStack(spacing: VFSpacing.small) {
                    Text("Great job!")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)

                    Text(reviewedCount == 1 ? "You reviewed 1 verse today." : "You reviewed \(reviewedCount) verses today.")
                        .font(VFFonts.body)
                        .foregroundStyle(VFColors.primaryNavy)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var statsCard: some View {
        VFCard(padding: VFSpacing.xLarge) {
            HStack(spacing: 0) {
                CompleteStatView(
                    systemImage: "checkmark",
                    iconColor: VFColors.successText,
                    iconBackground: VFColors.successGreen,
                    count: rememberedCount,
                    label: "remembered"
                )

                Rectangle()
                    .fill(VFColors.softBorder)
                    .frame(width: 1, height: 132)

                CompleteStatView(
                    systemImage: "arrow.clockwise",
                    iconColor: VFColors.softGold,
                    iconBackground: VFColors.warmCream,
                    count: needPracticeCount,
                    label: "need practice"
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct CompleteStatView: View {
    let systemImage: String
    let iconColor: Color
    let iconBackground: Color
    let count: Int
    let label: String

    var body: some View {
        VStack(spacing: VFSpacing.medium) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 80, height: 80)
                .background(iconBackground)
                .clipShape(Circle())

            VStack(spacing: VFSpacing.xSmall) {
                Text("\(count)")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundStyle(VFColors.primaryNavy)

                Text(label)
                    .font(VFFonts.body)
                    .foregroundStyle(VFColors.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct SparkleDot: View {
    let index: Int

    var body: some View {
        let positions: [(CGFloat, CGFloat, CGFloat)] = [
            (-96, -42, 16), (-72, 12, 7), (-48, -70, 5), (72, -58, 10), (96, -22, 18),
            (84, 42, 8), (-92, 54, 7), (42, -92, 6), (-18, -86, 8), (108, 20, 6)
        ]
        let item = positions[index % positions.count]

        Image(systemName: index.isMultiple(of: 3) ? "sparkle" : "diamond.fill")
            .font(.system(size: item.2, weight: .bold))
            .foregroundStyle(index.isMultiple(of: 2) ? VFColors.softGold : VFColors.primaryNavy)
            .offset(x: item.0, y: item.1)
    }
}

struct ReviewCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewCompleteView(
            reviewedCount: 5,
            rememberedCount: 3,
            needPracticeCount: 2
        ) {} onReviewAgain: {}
            .background(VFColors.warmCream)
    }
}
