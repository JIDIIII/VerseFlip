//
//  VFSecondaryButton.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct VFSecondaryButton: View {
    let title: String
    var systemImage: String?
    var isDisabled = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: VFSpacing.small) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 17, weight: .semibold))
                }

                Text(title)
                    .font(VFFonts.button)
            }
            .foregroundStyle(isDisabled ? VFColors.textMuted : VFColors.primaryNavy)
            .frame(maxWidth: .infinity)
            .frame(height: VFSpacing.buttonHeight)
            .background(VFColors.cardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous)
                    .stroke(VFColors.softBorder, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.65 : 1)
        .accessibilityLabel(title)
    }
}

struct VFSecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: VFSpacing.large) {
            VFSecondaryButton(title: "Choose Version", systemImage: "book.closed") {}
            VFSecondaryButton(title: "Cancel", isDisabled: true) {}
        }
        .padding()
        .background(VFColors.warmCream)
    }
}
