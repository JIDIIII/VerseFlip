//
//  VFCard.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct VFCard<Content: View>: View {
    var padding: CGFloat = VFSpacing.large
    var cornerRadius: CGFloat = VFSpacing.cardCornerRadius
    var showsBorder = true
    var showsShadow = true
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(VFColors.cardBackground)
            .overlay {
                if showsBorder {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(VFColors.softBorder, lineWidth: 1)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: showsShadow ? VFColors.shadow : .clear,
                radius: VFSpacing.cardShadowRadius,
                x: 0,
                y: VFSpacing.cardShadowYOffset
            )
    }
}

enum VFEmptyStateAlignment {
    case leading
    case center

    var horizontal: HorizontalAlignment {
        self == .center ? .center : .leading
    }

    var text: TextAlignment {
        self == .center ? .center : .leading
    }

    var frame: Alignment {
        self == .center ? .center : .leading
    }
}

struct VFEmptyStateView: View {
    let systemName: String
    let title: String
    let message: String
    var alignment: VFEmptyStateAlignment = .center

    var body: some View {
        VFCard {
            VStack(alignment: alignment.horizontal, spacing: VFSpacing.medium) {
                VFIconCircle(
                    systemName: systemName,
                    size: 60,
                    foregroundColor: VFColors.softGold,
                    backgroundColor: VFColors.warmCream
                )
                .accessibilityHidden(true)

                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundStyle(VFColors.primaryNavy)
                    .multilineTextAlignment(alignment.text)

                Text(message)
                    .font(VFFonts.body)
                    .foregroundStyle(VFColors.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(alignment.text)
            }
            .frame(maxWidth: .infinity, alignment: alignment.frame)
        }
        .accessibilityElement(children: .combine)
    }
}

struct VFHeaderAccessoryIcon: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 21, weight: .semibold))
            .foregroundStyle(VFColors.primaryNavy)
            .frame(width: 48, height: 48)
            .background(VFColors.cardBackground.opacity(0.65))
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(VFColors.softGold.opacity(0.85), lineWidth: 1)
            }
            .accessibilityHidden(true)
    }
}

struct VFCard_Previews: PreviewProvider {
    static var previews: some View {
        VFCard {
            VStack(alignment: .leading, spacing: VFSpacing.small) {
                Text("John 3:16")
                    .font(VFFonts.headline)
                    .foregroundStyle(VFColors.primaryNavy)
                Text("For God so loved the world...")
                    .font(VFFonts.body)
                    .foregroundStyle(VFColors.textDark)
            }
        }
        .padding()
        .background(VFColors.warmCream)
    }
}
