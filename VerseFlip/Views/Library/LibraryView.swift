//
//  LibraryView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct LibraryView: View {
    @StateObject private var viewModel: LibraryViewModel
    @State private var isShowingCreateDeck = false
    @State private var deckPendingDeletion: Deck?

    init(viewModel: LibraryViewModel = LibraryViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            VFColors.warmCream
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VFSpacing.xLarge) {
                    Text("Library")
                        .font(.system(size: 38, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)
                        .padding(.top, VFSpacing.large)

                    VFSearchBar(text: $viewModel.searchText, placeholder: "Search saved verses...")

                    decksSection

                    savedVersesSection
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
        .sheet(isPresented: $isShowingCreateDeck) {
            NavigationStack {
                CreateDeckView(viewModel: viewModel)
            }
            .presentationDetents([.medium])
        }
        .alert("Delete Deck?", isPresented: Binding(
            get: { deckPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    deckPendingDeletion = nil
                }
            }
        )) {
            Button("Cancel", role: .cancel) {
                deckPendingDeletion = nil
            }
            Button("Delete", role: .destructive) {
                if let deck = deckPendingDeletion {
                    viewModel.deleteDeck(deck)
                }
                deckPendingDeletion = nil
            }
        } message: {
            Text("This will delete the deck and all verses saved inside it. This action cannot be undone.")
        }
        .alert("Unable to Update Library", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.clearError()
                }
            }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Please try again.")
        }
    }

    private var decksSection: some View {
        VStack(alignment: .leading, spacing: VFSpacing.large) {
            Text("My Decks")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(VFColors.primaryNavy)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: VFSpacing.medium),
                    GridItem(.flexible(), spacing: VFSpacing.medium)
                ],
                alignment: .leading,
                spacing: VFSpacing.medium
            ) {
                ForEach(viewModel.decks) { deck in
                    NavigationLink {
                        DeckDetailView(deck: deck, viewModel: viewModel)
                    } label: {
                        DeckCardView(
                            deckName: viewModel.displayName(for: deck),
                            iconName: deck.iconName,
                            verseCount: viewModel.cardCount(for: deck)
                        )
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        if viewModel.canDelete(deck) {
                            Button(role: .destructive) {
                                deckPendingDeletion = deck
                            } label: {
                                Label("Delete Deck", systemImage: "trash")
                            }
                        }
                    }
                }

                Button {
                    isShowingCreateDeck = true
                } label: {
                    CreateDeckCard()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Create Deck")
            }
        }
    }

    private var savedVersesSection: some View {
        VStack(alignment: .leading, spacing: VFSpacing.medium) {
            HStack(alignment: .firstTextBaseline) {
                Text("Saved Verses")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundStyle(VFColors.primaryNavy)

                Spacer()

                Text(viewModel.savedVerseSummary)
                    .font(VFFonts.callout)
                    .foregroundStyle(VFColors.textMuted)
            }

            if viewModel.filteredCards.isEmpty {
                emptySavedVerses
            } else {
                VStack(spacing: VFSpacing.medium) {
                    ForEach(viewModel.filteredCards) { card in
                        SavedVerseRowView(
                            card: card,
                            deckName: viewModel.deckName(for: card.deckId),
                            onDelete: {
                                viewModel.deleteCard(card)
                            }
                        )
                    }
                }
            }
        }
    }

    private var emptySavedVerses: some View {
        VFEmptyStateView(
            systemName: "text.book.closed",
            title: viewModel.searchText.isEmpty ? "No saved verses yet." : "No verses found.",
            message: viewModel.searchText.isEmpty ? "Add your first verse to begin memorizing Scripture." : "Try a different reference, word, deck, or status.",
            alignment: .leading
        )
    }
}

private struct CreateDeckCard: View {
    var body: some View {
        VFCard(padding: VFSpacing.large) {
            VStack(spacing: VFSpacing.medium) {
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(VFColors.softGold)
                    .frame(width: 74, height: 74)
                    .overlay {
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 1.2, dash: [6, 4]))
                            .foregroundStyle(VFColors.softGold)
                    }

                Text("Create Deck")
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundStyle(VFColors.primaryNavy)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 128)
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LibraryView()
        }
    }
}
