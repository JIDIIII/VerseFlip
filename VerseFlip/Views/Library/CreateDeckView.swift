//
//  CreateDeckView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct CreateDeckView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var deckName = ""
    @State private var selectedIconName = "cross.fill"

    private let iconOptions = [
        "cross.fill",
        "heart.fill",
        "hands.sparkles.fill",
        "book.closed.fill",
        "star.fill",
        "sun.max.fill"
    ]

    var body: some View {
        ZStack {
            VFColors.warmCream
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: VFSpacing.xLarge) {
                HStack(alignment: .center) {
                    Text("Create Deck")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)

                    Spacer()

                    Button("Cancel") {
                        dismiss()
                    }
                    .font(VFFonts.bodyEmphasized)
                    .foregroundStyle(VFColors.primaryNavy)
                    .accessibilityLabel("Cancel")
                }

                VStack(alignment: .leading, spacing: VFSpacing.medium) {
                    Text("Deck Name")
                        .font(VFFonts.bodyEmphasized)
                        .foregroundStyle(VFColors.primaryNavy)

                    TextField("Faith", text: $deckName)
                        .font(VFFonts.body)
                        .foregroundStyle(VFColors.textDark)
                        .padding(.horizontal, VFSpacing.large)
                        .frame(height: 54)
                        .background(VFColors.cardBackground)
                        .overlay {
                            RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous)
                                .stroke(VFColors.softBorder, lineWidth: 1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
                        .accessibilityLabel("Deck name")
                }

                VStack(alignment: .leading, spacing: VFSpacing.medium) {
                    Text("Icon")
                        .font(VFFonts.bodyEmphasized)
                        .foregroundStyle(VFColors.primaryNavy)

                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: VFSpacing.medium), count: 3),
                        spacing: VFSpacing.medium
                    ) {
                        ForEach(iconOptions, id: \.self) { iconName in
                            Button {
                                selectedIconName = iconName
                            } label: {
                                Image(systemName: iconName)
                                    .font(.system(size: 23, weight: .semibold))
                                    .foregroundStyle(selectedIconName == iconName ? VFColors.cardBackground : VFColors.softGold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(selectedIconName == iconName ? VFColors.primaryNavy : VFColors.cardBackground)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous)
                                            .stroke(selectedIconName == iconName ? VFColors.primaryNavy : VFColors.softBorder, lineWidth: 1)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Deck icon \(iconName.replacingOccurrences(of: ".fill", with: ""))")
                            .accessibilityValue(selectedIconName == iconName ? "Selected" : "Not selected")
                        }
                    }
                }

                VFPrimaryButton(title: "Create Deck", systemImage: "plus") {
                    viewModel.createDeck(name: deckName, iconName: selectedIconName)
                    if viewModel.errorMessage == nil {
                        dismiss()
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, VFSpacing.xLarge)
            .padding(.top, VFSpacing.xLarge)
        }
    }
}

struct CreateDeckView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateDeckView(viewModel: LibraryViewModel())
        }
    }
}
