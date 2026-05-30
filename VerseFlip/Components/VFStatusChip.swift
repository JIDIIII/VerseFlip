//
//  VFStatusChip.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

enum VFStatusChipStatus: CaseIterable {
    case learning
    case reviewing
    case memorized
    case difficult

    var title: String {
        switch self {
        case .learning:
            return "Learning"
        case .reviewing:
            return "Reviewing"
        case .memorized:
            return "Memorized"
        case .difficult:
            return "Difficult"
        }
    }

    var foregroundColor: Color {
        switch self {
        case .learning, .reviewing:
            return VFColors.primaryNavy
        case .memorized:
            return VFColors.successText
        case .difficult:
            return VFColors.dangerRed
        }
    }

    var backgroundColor: Color {
        switch self {
        case .learning:
            return VFColors.learningBlue
        case .reviewing:
            return VFColors.warmCream
        case .memorized:
            return VFColors.successGreen
        case .difficult:
            return VFColors.dangerRed.opacity(0.12)
        }
    }
}

struct VFStatusChip: View {
    let status: VFStatusChipStatus

    var body: some View {
        Text(status.title)
            .font(VFFonts.chip)
            .foregroundStyle(status.foregroundColor)
            .padding(.horizontal, VFSpacing.medium)
            .padding(.vertical, VFSpacing.small)
            .background(status.backgroundColor)
            .clipShape(Capsule())
    }
}

struct VFStatusChip_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ForEach(VFStatusChipStatus.allCases, id: \.self) { status in
                VFStatusChip(status: status)
            }
        }
        .padding()
        .background(VFColors.cardBackground)
    }
}
