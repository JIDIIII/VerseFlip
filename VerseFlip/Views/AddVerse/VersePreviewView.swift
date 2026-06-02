//
//  VersePreviewView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct VersePreviewView: View {
    @ObservedObject var viewModel: AddVerseViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            VFColors.warmCream
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VFSpacing.xLarge) {
                    AddVerseTopBar(title: "Preview Card")

                    frontCard
                    backCard
                    deckSelector

                    VFPrimaryButton(title: "Save Card", systemImage: "square.and.arrow.down") {
                        viewModel.saveCard()
                    }
                    .padding(.top, VFSpacing.small)
                }
                .padding(.horizontal, VFSpacing.xLarge)
                .padding(.top, VFSpacing.large)
                .padding(.bottom, VFSpacing.xxLarge)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Card Saved", isPresented: Binding(
            get: { viewModel.didSaveCard },
            set: { isPresented in
                if !isPresented {
                    viewModel.clearSaveConfirmation()
                }
            }
        )) {
            Button("Done") {
                viewModel.clearSaveConfirmation()
                dismiss()
            }
        } message: {
            Text("Your verse was added to \(viewModel.selectedDeck.name).")
        }
        .alert("Unable to Save", isPresented: Binding(
            get: { viewModel.saveErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.clearSaveError()
                }
            }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.saveErrorMessage ?? "Please try again.")
        }
    }

    private var frontCard: some View {
        VFCard(padding: VFSpacing.xLarge) {
            VStack(alignment: .leading, spacing: VFSpacing.large) {
                HStack(spacing: VFSpacing.medium) {
                    Image(systemName: "bookmark.square")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(VFColors.softGold)

                    Text("Front Side")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)
                }

                Image(systemName: "book.closed.fill")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(VFColors.softGold)
                    .frame(width: 76, height: 76)
                    .background(VFColors.warmCream)
                    .clipShape(Circle())

                if viewModel.selectedVersionRequiresFetch {
                    Text(viewModel.previewVerseText)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(viewModel.previewReference)
                        .font(.system(size: 25, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)
                }

                copyrightNotice
            }
        }
    }

    private var backCard: some View {
        VFCard(padding: VFSpacing.xLarge) {
            VStack(alignment: .leading, spacing: VFSpacing.large) {
                HStack(spacing: VFSpacing.medium) {
                    Image(systemName: "rectangle.portrait")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(VFColors.softGold)

                    Text("Back Side")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)
                }

                if viewModel.selectedVersionRequiresFetch {
                    Text(viewModel.previewReference)
                        .font(.system(size: 25, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)

                    copyrightNotice
                } else {
                    Text("\"")
                        .font(.system(size: 48, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.softGold)
                        .frame(height: 32)

                    Text(viewModel.previewVerseText)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    @ViewBuilder
    private var copyrightNotice: some View {
        if let notice = viewModel.selectedVersion?.copyrightNotice {
            Text(notice)
                .font(VFFonts.footnote)
                .foregroundStyle(VFColors.textMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var deckSelector: some View {
        VStack(alignment: .leading, spacing: VFSpacing.medium) {
            Text("Deck")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(VFColors.primaryNavy)

            Menu {
                ForEach(viewModel.decks) { deck in
                    Button(deck.name) {
                        viewModel.selectedDeck = deck
                    }
                }
            } label: {
                HStack(spacing: VFSpacing.medium) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundStyle(VFColors.softGold)

                    Text(viewModel.selectedDeck.name)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(VFColors.primaryNavy)
                }
                .padding(.horizontal, VFSpacing.large)
                .frame(height: 62)
                .background(VFColors.cardBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous)
                        .stroke(VFColors.softBorder, lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
            }
            .accessibilityLabel("Deck")
            .accessibilityValue(viewModel.selectedDeck.name)
        }
    }
}

struct VersePreviewView_Previews: PreviewProvider {
    private static var previewViewModel: AddVerseViewModel {
        let viewModel = AddVerseViewModel()
        if let john = viewModel.books.first(where: { $0.name == "John" }) {
            viewModel.selectBook(john)
            viewModel.selectChapter(3)
            [16, 17].forEach { number in
                if let verse = viewModel.verses.first(where: { $0.number == number }) {
                    viewModel.toggleVerse(verse)
                }
            }
        }

        return viewModel
    }

    static var previews: some View {
        NavigationStack {
            VersePreviewView(viewModel: previewViewModel)
        }
    }
}
