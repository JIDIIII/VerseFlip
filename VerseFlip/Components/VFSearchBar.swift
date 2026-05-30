//
//  VFSearchBar.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct VFSearchBar: View {
    @Binding var text: String
    var placeholder = "Search"

    var body: some View {
        HStack(spacing: VFSpacing.small) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(VFColors.textMuted)

            TextField(placeholder, text: $text)
                .font(VFFonts.body)
                .foregroundStyle(VFColors.textDark)
                .vfSearchTextInputBehavior()
                .accessibilityLabel(placeholder)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(VFColors.textMuted)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, VFSpacing.large)
        .frame(height: 48)
        .background(VFColors.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous)
                .stroke(VFColors.softBorder, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
    }
}

private extension View {
    @ViewBuilder
    func vfSearchTextInputBehavior() -> some View {
        #if os(iOS)
        self
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        #else
        self
        #endif
    }
}

struct VFSearchBar_Previews: PreviewProvider {
    static var previews: some View {
        VFSearchBar(text: .constant("Romans"), placeholder: "Search books")
            .padding()
            .background(VFColors.warmCream)
    }
}
