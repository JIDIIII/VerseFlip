//
//  BookSelectionView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct BookSelectionView: View {
    @ObservedObject var viewModel: AddVerseViewModel
    @State private var searchText = ""

    var body: some View {
        ZStack {
            VFColors.warmCream
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VFSpacing.xLarge) {
                    AddVerseTopBar(title: "Select Book")

                    VFSearchBar(text: $searchText, placeholder: "Search book...")

                    testamentSection(.old, systemImage: "book.closed", books: books(for: .old))
                    testamentSection(.new, systemImage: "cross", books: books(for: .new))
                }
                .padding(.horizontal, VFSpacing.xLarge)
                .padding(.top, VFSpacing.large)
                .padding(.bottom, VFSpacing.xxLarge)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func books(for testament: Testament) -> [BibleBook] {
        viewModel.books.filter { book in
            book.testament == testament &&
            (searchText.isEmpty || book.name.localizedCaseInsensitiveContains(searchText))
        }
    }

    private func testamentSection(_ testament: Testament, systemImage: String, books: [BibleBook]) -> some View {
        VStack(alignment: .leading, spacing: VFSpacing.medium) {
            HStack(spacing: VFSpacing.medium) {
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(VFColors.softGold)
                    .frame(width: 32)

                Text(testament.rawValue)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundStyle(VFColors.primaryNavy)
            }

            if books.isEmpty {
                emptyBookState
            } else {
                VStack(spacing: 0) {
                    ForEach(books) { book in
                        NavigationLink {
                            ChapterSelectionView(viewModel: viewModel)
                        } label: {
                            bookRow(book)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            viewModel.selectBook(book)
                        })
                        .buttonStyle(.plain)
                        .accessibilityLabel("Select \(book.name)")

                        if book.id != books.last?.id {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
                .background(VFColors.cardBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: VFSpacing.cardCornerRadius, style: .continuous)
                        .stroke(VFColors.softBorder, lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: VFSpacing.cardCornerRadius, style: .continuous))
                .shadow(color: VFColors.shadow, radius: VFSpacing.cardShadowRadius, x: 0, y: VFSpacing.cardShadowYOffset)
            }
        }
    }

    private func bookRow(_ book: BibleBook) -> some View {
        HStack(spacing: VFSpacing.medium) {
            Image(systemName: "book")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(VFColors.softGold)
                .frame(width: 32)

            Text(book.name)
                .font(.system(size: 23, weight: .bold, design: .serif))
                .foregroundStyle(VFColors.primaryNavy)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(VFColors.textMuted)
        }
        .padding(.horizontal, VFSpacing.large)
        .frame(height: 68)
        .contentShape(Rectangle())
    }

    private var emptyBookState: some View {
        VFEmptyStateView(
            systemName: "book.closed",
            title: searchText.isEmpty ? "No books are available." : "No matching books.",
            message: searchText.isEmpty ? "Bible reference data could not be loaded." : "Try a different book name.",
            alignment: .leading
        )
    }
}

struct BookSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BookSelectionView(viewModel: AddVerseViewModel())
        }
    }
}
