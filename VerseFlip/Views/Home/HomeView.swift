//
//  HomeView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct HomeView: View {
    var onViewLibrary: () -> Void = {}

    @StateObject private var viewModel = HomeViewModel()
    @AppStorage("userNickname") private var userNickname = ""

    @State private var isShowingAddVerse = false
    @State private var isShowingReview = false

    var body: some View {
        ZStack {
            VFColors.warmCream
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VFSpacing.xLarge) {
                    header
                        .padding(.top, VFSpacing.large)

                    greeting

                    todayReviewCard

                    ProgressCardView(
                        versesSaved: viewModel.totalSavedVerses,
                        dueForReview: viewModel.dueForReviewCount,
                        memorized: viewModel.memorizedCount,
                        learning: viewModel.learningCount,
                        reviewing: viewModel.reviewingCount,
                        difficult: viewModel.difficultCount
                    )

                    TodayVerseCardView(
                        reference: "John 3:16 NIV",
                        verseText: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life."
                    )

                    quickActions
                        .padding(.bottom, VFSpacing.xLarge)
                }
                .padding(.horizontal, VFSpacing.xLarge)
                .padding(.bottom, VFSpacing.large)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.reload()
        }
        .navigationDestination(isPresented: $isShowingAddVerse) {
            BibleVersionSelectionView()
        }
        .navigationDestination(isPresented: $isShowingReview) {
            ReviewView(
                viewModel: ReviewViewModel(reviewingDueOnly: true),
                onBackToHome: {
                    viewModel.reload()
                    isShowingReview = false
                }
            )
        }
    }

    private var header: some View {
        HStack(spacing: VFSpacing.medium) {
            HomeLogoMark()
                .frame(width: 44, height: 50)

            Text("VerseFlip")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(VFColors.primaryNavy)

            Spacer()

            VFHeaderAccessoryIcon(systemName: "bell")
        }
    }

    private var greeting: some View {
        HStack(alignment: .top, spacing: VFSpacing.medium) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(VFColors.softGold)
                .padding(.top, 3)

            VStack(alignment: .leading, spacing: VFSpacing.xSmall) {
                Text(greetingText)
                    .font(.system(size: 27, weight: .bold, design: .serif))
                    .foregroundStyle(VFColors.primaryNavy)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text("Ready to review Scripture today?")
                    .font(VFFonts.body)
                    .foregroundStyle(VFColors.textMuted)
            }
        }
    }

    private var greetingText: String {
        let nickname = userNickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return nickname.isEmpty ? "Good morning" : "Good morning, \(nickname)"
    }

    private var todayReviewCard: some View {
        VFCard(padding: VFSpacing.large) {
            VStack(spacing: VFSpacing.large) {
                HStack(alignment: .center, spacing: VFSpacing.xLarge) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(VFColors.warmCream)
                            .frame(width: 104, height: 104)

                        Image(systemName: "menucard.fill")
                            .font(.system(size: 56, weight: .semibold))
                            .foregroundStyle(VFColors.primaryNavy)

                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(VFColors.softGold)
                            .background(Circle().fill(VFColors.cardBackground))
                            .offset(x: 4, y: 4)
                    }

                    VStack(alignment: .leading, spacing: VFSpacing.medium) {
                        Text("Today's Review")
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundStyle(VFColors.primaryNavy)

                        HStack(alignment: .firstTextBaseline, spacing: VFSpacing.medium) {
                            Text("\(viewModel.dueForReviewCount)")
                                .font(.system(size: 50, weight: .bold, design: .serif))
                                .foregroundStyle(VFColors.primaryNavy)

                            Text("cards due")
                                .font(VFFonts.body)
                                .foregroundStyle(VFColors.textMuted)
                        }
                    }

                    Spacer(minLength: 0)
                }

                VFPrimaryButton(
                    title: "Start Review",
                    systemImage: "play.fill",
                    isDisabled: viewModel.dueForReviewCount == 0
                ) {
                    viewModel.reload()
                    isShowingReview = true
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: VFSpacing.medium) {
            Text("Quick Actions")
                .font(.system(size: 21, weight: .bold, design: .serif))
                .foregroundStyle(VFColors.primaryNavy)

            HStack(spacing: VFSpacing.medium) {
                Button {
                    isShowingAddVerse = true
                } label: {
                    Label("Add Verse", systemImage: "plus")
                        .font(VFFonts.button)
                        .foregroundStyle(VFColors.cardBackground)
                        .frame(maxWidth: .infinity)
                        .frame(height: VFSpacing.buttonHeight)
                        .background(VFColors.primaryNavy)
                        .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
                        .shadow(color: VFColors.shadow, radius: VFSpacing.controlShadowRadius, x: 0, y: VFSpacing.controlShadowYOffset)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add Verse")

                Button {
                    onViewLibrary()
                } label: {
                    Label("View Library", systemImage: "book")
                        .font(VFFonts.button)
                        .foregroundStyle(VFColors.primaryNavy)
                        .frame(maxWidth: .infinity)
                        .frame(height: VFSpacing.buttonHeight)
                        .background(VFColors.cardBackground.opacity(0.55))
                        .overlay {
                            RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous)
                                .stroke(VFColors.primaryNavy, lineWidth: 1.2)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("View Library")
            }
        }
    }
}

private struct HomeLogoMark: View {
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
        }
    }
}
