//
//  VFPrimaryButton.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct VFPrimaryButton: View {
    let title: String
    var systemImage: String?
    var isLoading = false
    var isDisabled = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: VFSpacing.small) {
                if isLoading {
                    ProgressView()
                        .tint(VFColors.cardBackground)
                } else if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 17, weight: .semibold))
                }

                Text(title)
                    .font(VFFonts.button)
            }
            .foregroundStyle(VFColors.cardBackground)
            .frame(maxWidth: .infinity)
            .frame(height: VFSpacing.buttonHeight)
            .background(isDisabled ? VFColors.textMuted : VFColors.primaryNavy)
            .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
            .shadow(color: VFColors.shadow, radius: VFSpacing.controlShadowRadius, x: 0, y: VFSpacing.controlShadowYOffset)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.65 : 1)
        .accessibilityLabel(title)
        .accessibilityValue(isLoading ? "In progress" : "")
    }
}

struct VFPrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: VFSpacing.large) {
            VFPrimaryButton(title: "Start Review", systemImage: "play.fill") {}
            VFPrimaryButton(title: "Save Card", isLoading: true) {}
        }
        .padding()
        .background(VFColors.warmCream)
    }
}
