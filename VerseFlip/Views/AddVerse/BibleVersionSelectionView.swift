//
//  BibleVersionSelectionView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct BibleVersionSelectionView: View {
    @StateObject private var viewModel = AddVerseViewModel()

    var body: some View {
        ZStack {
            VFColors.warmCream
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VFSpacing.xLarge) {
                    AddVerseTopBar(title: "Add Verse")

                    VStack(alignment: .leading, spacing: VFSpacing.medium) {
                        HStack(spacing: VFSpacing.medium) {
                            Image(systemName: "book")
                                .font(.system(size: 31, weight: .medium))
                                .foregroundStyle(VFColors.softGold)

                            Text("Choose Bible Version")
                                .font(.system(size: 30, weight: .bold, design: .serif))
                                .foregroundStyle(VFColors.primaryNavy)
                        }

                        Text("Select a translation to add Scripture.")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(VFColors.textMuted)
                    }

                    VStack(spacing: VFSpacing.large) {
                        ForEach(viewModel.versionOptions) { version in
                            versionRow(for: version)
                        }
                    }

                    if let serviceMessage = viewModel.serviceMessage {
                        infoRow(message: serviceMessage, systemImage: "exclamationmark.triangle")
                    } else {
                        infoRow(message: "You can add one verse or a verse range.", systemImage: "info.circle")
                    }

                    NavigationLink {
                        selectedVersionDestination
                    } label: {
                        Text("Continue")
                            .font(VFFonts.button)
                            .foregroundStyle(VFColors.cardBackground)
                            .frame(maxWidth: .infinity)
                            .frame(height: VFSpacing.buttonHeight)
                            .background(viewModel.canContinueFromVersion ? VFColors.primaryNavy : VFColors.textMuted)
                            .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.canContinueFromVersion == false)
                    .padding(.top, VFSpacing.small)
                }
                .padding(.horizontal, VFSpacing.xLarge)
                .padding(.top, VFSpacing.large)
                .padding(.bottom, VFSpacing.xxLarge)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var selectedVersionDestination: some View {
        BookSelectionView(viewModel: viewModel)
    }

    private func versionRow(for version: BibleVersion) -> some View {
        let isSelected = viewModel.selectedVersion == version
        let isEnabled = viewModel.isVersionEnabled(version)
        let statusText = viewModel.versionStatusText(version)
        let unavailableMessage = isEnabled ? nil : viewModel.versionUnavailableMessage(version)

        return Button {
            viewModel.selectVersion(version)
        } label: {
            HStack(spacing: VFSpacing.large) {
                ZStack {
                    Circle()
                        .fill(VFColors.warmCream)
                        .frame(width: 64, height: 64)

                    Image(systemName: version == .kjv ? "text.book.closed.fill" : "network")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(VFColors.primaryNavy)
                }

                VStack(alignment: .leading, spacing: VFSpacing.xSmall) {
                    HStack(spacing: VFSpacing.small) {
                        Text(version.rawValue)
                            .font(.system(size: 27, weight: .bold, design: .serif))
                            .foregroundStyle(VFColors.primaryNavy)

                        if let statusText {
                            Text(statusText)
                                .font(VFFonts.chip)
                                .foregroundStyle(VFColors.textMuted)
                                .padding(.horizontal, VFSpacing.small)
                                .padding(.vertical, VFSpacing.xSmall)
                                .background(VFColors.warmCream)
                                .clipShape(Capsule())
                        }
                    }

                    Text(version.displayName)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(VFColors.textMuted)

                    if let unavailableMessage {
                        Text(unavailableMessage)
                            .font(VFFonts.footnote)
                            .foregroundStyle(VFColors.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: 0)

                ZStack {
                    Circle()
                        .stroke(isSelected ? VFColors.softGold : VFColors.softBorder, lineWidth: 2)
                        .frame(width: 34, height: 34)

                    if isSelected {
                        Circle()
                            .fill(VFColors.softGold)
                            .frame(width: 19, height: 19)
                    }
                }
            }
            .padding(VFSpacing.large)
            .frame(maxWidth: .infinity)
            .background(VFColors.cardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: VFSpacing.cardCornerRadius, style: .continuous)
                    .stroke(isSelected ? VFColors.softGold : VFColors.softBorder, lineWidth: isSelected ? 1.4 : 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: VFSpacing.cardCornerRadius, style: .continuous))
            .shadow(color: VFColors.shadow, radius: VFSpacing.cardShadowRadius, x: 0, y: VFSpacing.cardShadowYOffset)
            .opacity(isEnabled ? 1 : 0.62)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel("\(version.rawValue), \(version.displayName)")
        .accessibilityValue(isSelected ? "Selected" : statusText ?? "Available")
    }

    private func infoRow(message: String, systemImage: String) -> some View {
        HStack(spacing: VFSpacing.medium) {
            Image(systemName: systemImage)
                .font(.system(size: 23, weight: .medium))
                .foregroundStyle(VFColors.primaryNavy)

            Text(message)
                .font(VFFonts.callout)
                .foregroundStyle(VFColors.primaryNavy)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(VFSpacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(VFColors.cardBackground.opacity(0.72))
        .overlay {
            RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous)
                .stroke(VFColors.softBorder, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
    }
}

struct AddVerseTopBar: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    var trailingSystemImage: String?

    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 27, weight: .bold, design: .serif))
                .foregroundStyle(VFColors.primaryNavy)
                .frame(maxWidth: .infinity)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(VFColors.primaryNavy)
                        .frame(width: 56, height: 56)
                }
                .background(VFColors.cardBackground.opacity(0.72))
                .overlay {
                    Circle()
                        .stroke(VFColors.softGold, lineWidth: 1)
                }
                .clipShape(Circle())
                .buttonStyle(.plain)
                .accessibilityLabel("Back")

                Spacer()

                if let trailingSystemImage {
                    VFHeaderAccessoryIcon(systemName: trailingSystemImage)
                        .frame(width: 56, height: 56)
                }
            }
        }
        .frame(height: 60)
    }
}

struct BibleVersionSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BibleVersionSelectionView()
        }
    }
}
