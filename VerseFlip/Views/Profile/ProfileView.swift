//
//  ProfileView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = HomeViewModel()

    @AppStorage("preferredBibleVersion") private var preferredBibleVersionRawValue = BibleVersion.kjv.rawValue

    @State private var isShowingResetConfirmation = false
    @State private var errorMessage: String?

    private var activeLearningCount: Int {
        max(viewModel.totalSavedVerses - viewModel.memorizedCount, 0)
    }

    var body: some View {
        ZStack {
            VFColors.warmCream
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VFSpacing.xLarge) {
                    profileHeader
                        .padding(.top, VFSpacing.large)

                    progressSection

                    settingsSection

                    resetSection
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
        .alert("Reset Progress?", isPresented: $isShowingResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset Progress", role: .destructive) {
                resetProgress()
            }
        } message: {
            Text("This will keep your saved verses and set every card back to Learning.")
        }
        .alert("Unable to Reset Progress", isPresented: Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Please try again.")
        }
    }

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: VFSpacing.large) {
            HStack(spacing: VFSpacing.medium) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(VFColors.softGold)
                    .frame(width: 64, height: 64)
                    .background(VFColors.cardBackground.opacity(0.75))
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(VFColors.softGold.opacity(0.85), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: VFSpacing.xSmall) {
                    Text("Profile")
                        .font(.system(size: 44, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)

                    Text("Your VerseFlip progress and preferences")
                        .font(VFFonts.body)
                        .foregroundStyle(VFColors.textMuted)
                }
            }
        }
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: VFSpacing.medium) {
            Text("Progress")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(VFColors.primaryNavy)

            VFCard(padding: VFSpacing.large) {
                VStack(spacing: VFSpacing.large) {
                    HStack(spacing: VFSpacing.medium) {
                        ProfileStatTile(
                            title: "Total Saved Verses",
                            value: "\(viewModel.totalSavedVerses)",
                            systemImage: "bookmark.fill",
                            tint: VFColors.softGold,
                            background: VFColors.warmCream
                        )

                        ProfileStatTile(
                            title: "Memorized",
                            value: "\(viewModel.memorizedCount)",
                            systemImage: "crown.fill",
                            tint: VFColors.successText,
                            background: VFColors.successGreen
                        )
                    }

                    HStack(spacing: VFSpacing.medium) {
                        ProfileStatTile(
                            title: "Learning",
                            value: "\(activeLearningCount)",
                            systemImage: "arrow.clockwise",
                            tint: VFColors.primaryNavy,
                            background: VFColors.learningBlue
                        )

                        ProfileStatTile(
                            title: "Current Streak",
                            value: "0 days",
                            systemImage: "flame.fill",
                            tint: VFColors.dangerRed,
                            background: VFColors.dangerRed.opacity(0.12)
                        )
                    }
                }
            }
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: VFSpacing.medium) {
            Text("Settings")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(VFColors.primaryNavy)

            VFCard(padding: 0) {
                VStack(spacing: 0) {
                    PickerRow(
                        title: "Preferred Bible Version",
                        systemImage: "book.closed.fill",
                        selection: $preferredBibleVersionRawValue
                    )

                    settingsDivider

                    StatusRow(
                        title: "Daily Reminder",
                        subtitle: "Not included in the MVP.",
                        systemImage: "bell.fill"
                    )

                    settingsDivider

                    StatusRow(
                        title: "Dark Mode",
                        subtitle: "Uses the current system appearance.",
                        systemImage: "moon.fill"
                    )
                }
            }
        }
    }

    private var resetSection: some View {
        VStack(alignment: .leading, spacing: VFSpacing.medium) {
            Text("Progress Controls")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(VFColors.primaryNavy)

            VFCard {
                VStack(alignment: .leading, spacing: VFSpacing.large) {
                    HStack(alignment: .top, spacing: VFSpacing.medium) {
                        VFIconCircle(
                            systemName: "arrow.counterclockwise",
                            size: 52,
                            foregroundColor: VFColors.dangerRed,
                            backgroundColor: VFColors.dangerRed.opacity(0.12)
                        )

                        VStack(alignment: .leading, spacing: VFSpacing.xSmall) {
                            Text("Reset review progress")
                                .font(.system(size: 21, weight: .bold, design: .serif))
                                .foregroundStyle(VFColors.primaryNavy)

                            Text("Saved verses stay in your library. Review status and review dates are reset.")
                                .font(VFFonts.callout)
                                .foregroundStyle(VFColors.textMuted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Button {
                        isShowingResetConfirmation = true
                    } label: {
                        Label("Reset Progress", systemImage: "arrow.counterclockwise")
                            .font(VFFonts.button)
                            .foregroundStyle(VFColors.dangerRed)
                            .frame(maxWidth: .infinity)
                            .frame(height: VFSpacing.buttonHeight)
                            .background(VFColors.cardBackground)
                            .overlay {
                                RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous)
                                    .stroke(VFColors.dangerRed, lineWidth: 1.2)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.totalSavedVerses == 0)
                    .opacity(viewModel.totalSavedVerses == 0 ? 0.55 : 1)
                }
            }
        }
    }

    private var settingsDivider: some View {
        Rectangle()
            .fill(VFColors.softBorder)
            .frame(height: 1)
            .padding(.leading, 64)
    }

    private func resetProgress() {
        let store = VerseCardStore()
        var resetCards = store.cards

        for index in resetCards.indices {
            resetCards[index].reviewStatus = .learning
            resetCards[index].lastReviewedAt = nil
        }

        do {
            for card in resetCards {
                try store.upsert(card)
            }
            viewModel.reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct ProfileStatTile: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color
    let background: Color

    var body: some View {
        VStack(alignment: .leading, spacing: VFSpacing.medium) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 46, height: 46)
                .background(background)
                .clipShape(Circle())

            Text(value)
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundStyle(VFColors.primaryNavy)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(title)
                .font(VFFonts.callout)
                .foregroundStyle(VFColors.textMuted)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 146, alignment: .topLeading)
        .padding(VFSpacing.large)
        .background(VFColors.warmCream.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
    }
}

private struct PickerRow: View {
    let title: String
    let systemImage: String
    @Binding var selection: String

    var body: some View {
        HStack(spacing: VFSpacing.medium) {
            SettingsIcon(systemName: systemImage)

            Text(title)
                .font(VFFonts.bodyEmphasized)
                .foregroundStyle(VFColors.primaryNavy)

            Spacer()

            Picker(title, selection: $selection) {
                ForEach(BibleVersion.allCases) { version in
                    Text(version.rawValue)
                        .tag(version.rawValue)
                }
            }
            .tint(VFColors.primaryNavy)
        }
        .padding(.horizontal, VFSpacing.large)
        .padding(.vertical, VFSpacing.medium)
    }
}

private struct StatusRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: VFSpacing.medium) {
            SettingsIcon(systemName: systemImage)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(VFFonts.bodyEmphasized)
                    .foregroundStyle(VFColors.primaryNavy)

                Text(subtitle)
                    .font(VFFonts.footnote)
                    .foregroundStyle(VFColors.textMuted)
            }

            Spacer()

            Text("MVP")
                .font(VFFonts.chip)
                .foregroundStyle(VFColors.primaryNavy)
                .padding(.horizontal, VFSpacing.medium)
                .padding(.vertical, VFSpacing.small)
                .background(VFColors.warmCream)
                .clipShape(Capsule())
        }
        .padding(.horizontal, VFSpacing.large)
        .padding(.vertical, VFSpacing.medium)
        .accessibilityElement(children: .combine)
    }
}

private struct SettingsIcon: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(VFColors.softGold)
            .frame(width: 36, height: 36)
            .background(VFColors.warmCream)
            .clipShape(Circle())
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
        }
    }
}
