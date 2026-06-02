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
                    greeting
                        .padding(.top, VFSpacing.large)

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
        let greeting = timeBasedGreeting
        return nickname.isEmpty ? greeting : "\(greeting), \(nickname)"
    }

    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }

    private var todayReviewCard: some View {
        VFCard(padding: VFSpacing.xLarge) {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center, spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(VFColors.warmCream.opacity(0.8))
                            .frame(width: 100, height: 100)

                        Image(systemName: "rectangle.stack.fill")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundStyle(VFColors.primaryNavy)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(VFColors.softGold)
                            .background(Circle().fill(VFColors.cardBackground))
                    }
                    .frame(width: 100, height: 100)
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: VFSpacing.small) {
                        Text("Today's Review")
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundStyle(VFColors.primaryNavy)

                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Text("\(viewModel.dueForReviewCount)")
                                .font(.system(size: 36, weight: .bold, design: .serif))
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
        }
    }
}
