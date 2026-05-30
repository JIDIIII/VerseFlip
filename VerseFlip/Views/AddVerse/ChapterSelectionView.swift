//
//  ChapterSelectionView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct ChapterSelectionView: View {
    @ObservedObject var viewModel: AddVerseViewModel

    private let columns = [
        GridItem(.flexible(), spacing: VFSpacing.large),
        GridItem(.flexible(), spacing: VFSpacing.large),
        GridItem(.flexible(), spacing: VFSpacing.large)
    ]

    var body: some View {
        ZStack {
            VFColors.warmCream
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: VFSpacing.xLarge) {
                        AddVerseTopBar(title: viewModel.selectedBook?.name ?? "Select Chapter", trailingSystemImage: "bell")

                        VStack(alignment: .leading, spacing: VFSpacing.medium) {
                            HStack(spacing: VFSpacing.medium) {
                                Image(systemName: "bookmark.square")
                                    .font(.system(size: 30, weight: .medium))
                                    .foregroundStyle(VFColors.softGold)

                                Text("Select Chapter")
                                    .font(.system(size: 30, weight: .bold, design: .serif))
                                    .foregroundStyle(VFColors.primaryNavy)
                            }

                            Text("Choose a chapter to review.")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(VFColors.textMuted)
                        }

                        if viewModel.chapters.isEmpty {
                            emptyChapterState
                        } else {
                            LazyVGrid(columns: columns, spacing: VFSpacing.large) {
                                ForEach(viewModel.chapters) { chapter in
                                    chapterButton(chapter.number)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, VFSpacing.xLarge)
                    .padding(.top, VFSpacing.large)
                    .padding(.bottom, 110)
                }

                NavigationLink {
                    VerseSelectionView(viewModel: viewModel)
                } label: {
                    Label("Continue", systemImage: "play.fill")
                        .font(VFFonts.button)
                        .foregroundStyle(VFColors.cardBackground)
                        .frame(maxWidth: .infinity)
                        .frame(height: VFSpacing.buttonHeight)
                        .background(viewModel.canContinueFromChapter ? VFColors.primaryNavy : VFColors.textMuted)
                        .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
                        .shadow(color: VFColors.shadow, radius: VFSpacing.controlShadowRadius, x: 0, y: VFSpacing.controlShadowYOffset)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.canContinueFromChapter == false)
                .padding(.horizontal, VFSpacing.xLarge)
                .padding(.top, VFSpacing.medium)
                .padding(.bottom, VFSpacing.large)
                .background(VFColors.warmCream)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func chapterButton(_ chapterNumber: Int) -> some View {
        let isSelected = viewModel.selectedChapter == chapterNumber

        return Button {
            viewModel.selectChapter(chapterNumber)
        } label: {
            ZStack(alignment: .topTrailing) {
                Text("\(chapterNumber)")
                    .font(.system(size: 39, weight: .bold, design: .serif))
                    .foregroundStyle(isSelected ? VFColors.cardBackground : VFColors.primaryNavy)
                    .frame(maxWidth: .infinity)
                    .frame(height: 98)
                    .background(isSelected ? VFColors.primaryNavy : VFColors.cardBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: VFSpacing.cardCornerRadius, style: .continuous)
                            .stroke(isSelected ? VFColors.softGold : VFColors.softBorder, lineWidth: isSelected ? 2 : 1)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: VFSpacing.cardCornerRadius, style: .continuous))
                    .shadow(color: VFColors.shadow, radius: VFSpacing.cardShadowRadius, x: 0, y: VFSpacing.cardShadowYOffset)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(VFColors.softGold)
                        .background(Circle().fill(VFColors.cardBackground))
                        .offset(x: 8, y: -8)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Chapter \(chapterNumber)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }

    private var emptyChapterState: some View {
        VFEmptyStateView(
            systemName: "bookmark.square",
            title: "No chapters are available for this book.",
            message: "Go back and choose a different book.",
            alignment: .leading
        )
    }
}

struct ChapterSelectionView_Previews: PreviewProvider {
    private static var previewViewModel: AddVerseViewModel {
        let viewModel = AddVerseViewModel()
        if let john = viewModel.books.first(where: { $0.name == "John" }) {
            viewModel.selectBook(john)
            viewModel.selectChapter(3)
        }

        return viewModel
    }

    static var previews: some View {
        NavigationStack {
            ChapterSelectionView(viewModel: previewViewModel)
        }
    }
}
