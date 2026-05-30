//
//  VFBackButton.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct VFBackButton: View {
    @Environment(\.dismiss) private var dismiss

    var title = "Back"
    var action: (() -> Void)?

    var body: some View {
        Button {
            if let action = action {
                action()
            } else {
                dismiss()
            }
        } label: {
            HStack(spacing: VFSpacing.xSmall) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))

                Text(title)
                    .font(VFFonts.bodyEmphasized)
            }
            .foregroundStyle(VFColors.primaryNavy)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct VFBackButton_Previews: PreviewProvider {
    static var previews: some View {
        VFBackButton()
            .padding()
            .background(VFColors.warmCream)
    }
}
