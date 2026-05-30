//
//  ReviewView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct ReviewView: View {
    var onBackToHome: () -> Void = {}

    @StateObject private var viewModel: ReviewViewModel

    init(
        viewModel: ReviewViewModel = ReviewViewModel(),
        onBackToHome: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onBackToHome = onBackToHome
    }

    var body: some View {
        ZStack {
            VFColors.warmCream
                .ignoresSafeArea()

            if viewModel.isComplete {
                ReviewCompleteView(
                    reviewedCount: viewModel.reviewedCount,
                    rememberedCount: viewModel.rememberedCount,
                    needPracticeCount: viewModel.needPracticeCount,
                    onBackToHome: onBackToHome,
                    onReviewAgain: {
                        viewModel.reviewAgain()
                    }
                )
            } else if let card = viewModel.currentCard {
                reviewContent(for: card)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                emptyState
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: viewModel.currentIndex)
        .animation(.easeInOut(duration: 0.22), value: viewModel.isComplete)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.reload()
        }
        .alert("Unable to Save Review", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.clearError()
                }
            }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Please try again.")
        }
    }

    private func reviewContent(for card: VerseCard) -> some View {
        GeometryReader { geometry in
            let cardHeight = min(max(geometry.size.height * 0.44, 300), 420)

            ScrollView(showsIndicators: false) {
                VStack(spacing: VFSpacing.large) {
                    reviewHeader
                        .padding(.top, VFSpacing.large)

                    VStack(spacing: VFSpacing.small) {
                        Text("Review")
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .foregroundStyle(VFColors.primaryNavy)

                        Text("Card \(viewModel.currentCardNumber) of \(viewModel.totalCount)")
                            .font(VFFonts.body)
                            .foregroundStyle(VFColors.primaryNavy)

                        ProgressSegments(total: viewModel.totalCount, currentIndex: viewModel.currentIndex)
                    }

                    deckSelector

                    FlipCardView(
                        card: card,
                        isShowingVerse: viewModel.isFlipped,
                        maxCardHeight: cardHeight,
                        onTap: {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                                viewModel.toggleFlip()
                            }
                        }
                    )

                    reviewButtons
                        .padding(.bottom, VFSpacing.xLarge)
                }
                .padding(.horizontal, VFSpacing.xLarge)
                .padding(.bottom, VFSpacing.large)
            }
        }
    }

    private var reviewHeader: some View {
        HStack(spacing: VFSpacing.medium) {
            ReviewLogoMark()
                .frame(width: 44, height: 50)

            Text("VerseFlip")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(VFColors.primaryNavy)

            Spacer()

            VFHeaderAccessoryIcon(systemName: "bell")
        }
    }

    private var reviewButtons: some View {
        HStack(spacing: VFSpacing.medium) {
            ReviewGradeButton(
                title: "Again",
                subtitle: "Hard to recall",
                systemImage: "arrow.clockwise",
                color: VFColors.dangerRed,
                action: submitAgain
            )

            ReviewGradeButton(
                title: "Good",
                subtitle: "Somewhat easy",
                systemImage: "star.fill",
                color: VFColors.softGold,
                action: submitGood
            )

            ReviewGradeButton(
                title: "Memorized",
                subtitle: "Very easy",
                systemImage: "crown",
                color: VFColors.softGold,
                action: submitMemorized
            )
        }
    }

    private var deckSelector: some View {
        Menu {
            ForEach(viewModel.decks) { deck in
                Button(viewModel.displayName(for: deck)) {
                    viewModel.selectDeck(deck)
                }
            }
        } label: {
            VFCard(padding: VFSpacing.medium) {
                HStack(spacing: VFSpacing.medium) {
                    Image(systemName: "menucard")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(VFColors.primaryNavy)
                        .frame(width: 38)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Review Deck")
                            .font(VFFonts.footnote)
                            .foregroundStyle(VFColors.textMuted)

                        Text(viewModel.selectedDeckName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(VFColors.primaryNavy)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(VFColors.primaryNavy)
                }
                .frame(minHeight: 48)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Review deck")
        .accessibilityValue(viewModel.selectedDeckName)
    }

    private var emptyState: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: VFSpacing.xLarge) {
                reviewHeader
                    .padding(.top, VFSpacing.large)

                Text("Review")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundStyle(VFColors.primaryNavy)

                deckSelector

                VFEmptyStateView(
                    systemName: "rectangle.on.rectangle.angled",
                    title: "No cards in this deck yet.",
                    message: "Add verses to \(viewModel.selectedDeckName) to start reviewing."
                )

                Spacer(minLength: VFSpacing.xLarge)
            }
            .padding(.horizontal, VFSpacing.xLarge)
            .padding(.bottom, VFSpacing.large)
        }
    }

    private func submitAgain() {
        withAnimation(.easeInOut(duration: 0.22)) {
            viewModel.markAgain()
        }
    }

    private func submitGood() {
        withAnimation(.easeInOut(duration: 0.22)) {
            viewModel.markGood()
        }
    }

    private func submitMemorized() {
        withAnimation(.easeInOut(duration: 0.22)) {
            viewModel.markMemorized()
        }
    }
}

private struct ProgressSegments: View {
    let total: Int
    let currentIndex: Int

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: segmentSpacing) {
                ForEach(0..<displayTotal, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentIndex ? VFColors.softGold : VFColors.softBorder)
                        .frame(width: segmentWidth(in: proxy.size.width), height: 8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: 8)
        .accessibilityLabel("Review progress")
        .accessibilityValue("Card \(min(currentIndex + 1, max(total, 1))) of \(max(total, 1))")
    }

    private var displayTotal: Int {
        max(total, 1)
    }

    private var segmentSpacing: CGFloat {
        displayTotal > 24 ? 2 : 4
    }

    private func segmentWidth(in width: CGFloat) -> CGFloat {
        let availableWidth = max(width - CGFloat(displayTotal - 1) * segmentSpacing, CGFloat(displayTotal))
        return min(42, max(4, availableWidth / CGFloat(displayTotal)))
    }
}

private struct ReviewGradeButton: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: VFSpacing.small) {
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(height: 34)

                VStack(spacing: VFSpacing.xSmall) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(subtitle)
                        .font(VFFonts.footnote)
                        .foregroundStyle(VFColors.textMuted)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.82)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 118)
            .background(VFColors.cardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: VFSpacing.cardCornerRadius, style: .continuous)
                    .stroke(VFColors.softBorder, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: VFSpacing.cardCornerRadius, style: .continuous))
            .shadow(color: VFColors.shadow, radius: VFSpacing.cardShadowRadius, x: 0, y: VFSpacing.cardShadowYOffset)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
    }
}

private struct ReviewLogoMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(VFColors.softGold, lineWidth: 3)
                .frame(width: 31, height: 41)
                .overlay(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(VFColors.softGold, lineWidth: 3)
                        .frame(width: 23, height: 11)
                        .background(VFColors.warmCream)
                        .offset(y: 1)
                }

            Image(systemName: "cross")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(VFColors.softGold)
                .offset(y: -7)

            Image(systemName: "arrow.right")
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(VFColors.softGold)
                .offset(x: 18, y: 19)
        }
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReviewView()
        }
    }
}
