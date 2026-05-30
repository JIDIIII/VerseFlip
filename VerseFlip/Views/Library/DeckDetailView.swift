//
//  DeckDetailView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct DeckDetailView: View {
    let deck: Deck
    @ObservedObject var viewModel: LibraryViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingDeleteDeckConfirmation = false

    var body: some View {
        ZStack {
            VFColors.warmCream
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VFSpacing.xLarge) {
                    AddVerseTopBar(title: viewModel.displayName(for: deck))
                        .padding(.top, VFSpacing.large)

                    deckSummary

                    VStack(alignment: .leading, spacing: VFSpacing.medium) {
                        Text("Saved Verses")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundStyle(VFColors.primaryNavy)

                        if deckCards.isEmpty {
                            emptyState
                        } else {
                            VStack(spacing: VFSpacing.medium) {
                                ForEach(deckCards) { card in
                                    SavedVerseRowView(
                                        card: card,
                                        deckName: viewModel.displayName(for: deck),
                                        showsDeckName: false,
                                        onDelete: {
                                            viewModel.deleteCard(card)
                                        }
                                    )
                                }
                            }
                        }
                    }
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
        .alert("Delete Deck?", isPresented: $isShowingDeleteDeckConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteDeck(deck)
                dismiss()
            }
        } message: {
            Text("This will delete the deck and all verses saved inside it. This action cannot be undone.")
        }
    }

    private var deckCards: [VerseCard] {
        viewModel.cards(in: deck)
    }

    private var deckSummary: some View {
        VFCard(padding: VFSpacing.xLarge) {
            HStack(spacing: VFSpacing.large) {
                VFIconCircle(
                    systemName: deck.iconName,
                    size: 72,
                    foregroundColor: VFColors.softGold,
                    backgroundColor: VFColors.warmCream
                )

                VStack(alignment: .leading, spacing: VFSpacing.xSmall) {
                    Text(viewModel.displayName(for: deck))
                        .font(.system(size: 23, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)
                        .lineLimit(2)

                    Text(deckCards.count == 1 ? "1 saved verse" : "\(deckCards.count) saved verses")
                        .font(VFFonts.body)
                        .foregroundStyle(VFColors.textMuted)
                }

                Spacer()

                if viewModel.canDelete(deck) {
                    Button(role: .destructive) {
                        isShowingDeleteDeckConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(VFColors.dangerRed)
                            .frame(width: 42, height: 42)
                            .background(VFColors.dangerRed.opacity(0.10))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Delete deck")
                }
            }
        }
    }

    private var emptyState: some View {
        VFEmptyStateView(
            systemName: "books.vertical",
            title: "No saved verses in this deck.",
            message: "Choose this deck when saving a verse to collect cards here.",
            alignment: .leading
        )
    }
}

struct DeckDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DeckDetailView(deck: Deck.defaultDeck, viewModel: LibraryViewModel())
        }
    }
}
