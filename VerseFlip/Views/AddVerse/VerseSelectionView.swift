//
//  VerseSelectionView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct VerseSelectionView: View {
    @ObservedObject var viewModel: AddVerseViewModel
    @State private var isShowingPreview = false

    private let numberColumns = [
        GridItem(.adaptive(minimum: 76), spacing: VFSpacing.medium)
    ]

    var body: some View {
        ZStack {
            VFColors.warmCream
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: VFSpacing.xLarge) {
                            AddVerseTopBar(title: verseTitle, trailingSystemImage: "bell")

                            VStack(alignment: .leading, spacing: VFSpacing.medium) {
                                HStack(spacing: VFSpacing.medium) {
                                    Image(systemName: "book")
                                        .font(.system(size: 30, weight: .medium))
                                        .foregroundStyle(VFColors.softGold)

                                    Text("Select Verse")
                                        .font(.system(size: 30, weight: .bold, design: .serif))
                                        .foregroundStyle(VFColors.primaryNavy)
                                }

                                Text("Choose one or more verses to add to your review.")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundStyle(VFColors.textMuted)
                            }

                            if viewModel.verses.isEmpty {
                                emptyVerseState
                            } else if viewModel.selectedVersionRequiresFetch {
                                numberOnlyVerseGrid
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(viewModel.verses) { verse in
                                        verseRow(verse)
                                            .id(verse.number)

                                        if verse.id != viewModel.verses.last?.id {
                                            Divider()
                                                .padding(.leading, 64)
                                        }
                                    }
                                }
                                .padding(.vertical, VFSpacing.small)
                                .background(VFColors.cardBackground)
                                .overlay {
                                    RoundedRectangle(cornerRadius: VFSpacing.cardCornerRadius, style: .continuous)
                                        .stroke(VFColors.softBorder, lineWidth: 1)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: VFSpacing.cardCornerRadius, style: .continuous))
                                .shadow(color: VFColors.shadow, radius: VFSpacing.cardShadowRadius, x: 0, y: VFSpacing.cardShadowYOffset)
                            }

                            if viewModel.selectedVersionRequiresFetch,
                               let errorMessage = viewModel.passageFetchErrorMessage {
                                errorRow(errorMessage)
                            }
                        }
                        .padding(.horizontal, VFSpacing.xLarge)
                        .padding(.top, VFSpacing.large)
                        .padding(.bottom, 110)
                    }
                    .onAppear {
                        if viewModel.selectedBook?.name == "John",
                           viewModel.selectedChapter == 3,
                           viewModel.verses.contains(where: { $0.number == 16 }) {
                            proxy.scrollTo(16, anchor: .center)
                        }
                    }
                }

                Group {
                    if viewModel.selectedVersionRequiresFetch {
                        Button {
                            fetchSelectedPassage()
                        } label: {
                            actionButtonLabel
                        }
                        .disabled(viewModel.canPreviewSelection == false || viewModel.isFetchingPassage)
                    } else {
                        NavigationLink {
                            VersePreviewView(viewModel: viewModel)
                        } label: {
                            actionButtonLabel
                        }
                        .disabled(viewModel.canPreviewSelection == false)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, VFSpacing.xLarge)
                .padding(.top, VFSpacing.medium)
                .padding(.bottom, VFSpacing.large)
                .background(VFColors.warmCream)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $isShowingPreview) {
            VersePreviewView(viewModel: viewModel)
        }
    }

    private var verseTitle: String {
        guard let bookName = viewModel.selectedBook?.name,
              let chapter = viewModel.selectedChapter
        else {
            return "Select Verse"
        }

        return "\(bookName) \(chapter)"
    }

    private var buttonTitle: String {
        let count = viewModel.selectedVerseList.count
        return count == 0 ? "Add Selected Verse" : "Add Selected Verse (\(count))"
    }

    private var actionButtonLabel: some View {
        Label {
            Text(viewModel.isFetchingPassage ? "Fetching Verse..." : buttonTitle)
        } icon: {
            if viewModel.isFetchingPassage {
                ProgressView()
                    .tint(VFColors.cardBackground)
            } else {
                Image(systemName: "plus")
            }
        }
        .font(VFFonts.button)
        .foregroundStyle(VFColors.cardBackground)
        .frame(maxWidth: .infinity)
        .frame(height: VFSpacing.buttonHeight)
        .background(viewModel.canPreviewSelection && viewModel.isFetchingPassage == false ? VFColors.primaryNavy : VFColors.textMuted)
        .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
        .shadow(color: VFColors.shadow, radius: VFSpacing.controlShadowRadius, x: 0, y: VFSpacing.controlShadowYOffset)
    }

    private var numberOnlyVerseGrid: some View {
        LazyVGrid(columns: numberColumns, spacing: VFSpacing.medium) {
            ForEach(viewModel.verses) { verse in
                verseNumberButton(verse)
            }
        }
    }

    private func verseNumberButton(_ verse: BibleVerse) -> some View {
        let isSelected = viewModel.isVerseSelected(verse)

        return Button {
            viewModel.toggleVerse(verse)
        } label: {
            ZStack(alignment: .topTrailing) {
                Text("\(verse.number)")
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundStyle(isSelected ? VFColors.cardBackground : VFColors.primaryNavy)
                    .frame(maxWidth: .infinity)
                    .frame(height: 72)
                    .background(isSelected ? VFColors.primaryNavy : VFColors.cardBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: VFSpacing.cardCornerRadius, style: .continuous)
                            .stroke(isSelected ? VFColors.softGold : VFColors.softBorder, lineWidth: isSelected ? 2 : 1)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: VFSpacing.cardCornerRadius, style: .continuous))
                    .shadow(color: VFColors.shadow, radius: VFSpacing.cardShadowRadius, x: 0, y: VFSpacing.cardShadowYOffset)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(VFColors.softGold)
                        .background(Circle().fill(VFColors.cardBackground))
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Verse \(verse.number)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }

    private func verseRow(_ verse: BibleVerse) -> some View {
        let isSelected = viewModel.isVerseSelected(verse)

        return Button {
            viewModel.toggleVerse(verse)
        } label: {
            HStack(alignment: .top, spacing: VFSpacing.large) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? VFColors.primaryNavy : VFColors.primaryNavy, lineWidth: 1.5)
                        .frame(width: 36, height: 36)

                    if isSelected {
                        Circle()
                            .fill(VFColors.primaryNavy)
                            .frame(width: 36, height: 36)

                        Image(systemName: "checkmark")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(VFColors.cardBackground)
                    }
                }
                .padding(.top, 4)

                Text("\(verse.number)")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(VFColors.primaryNavy)
                    .frame(width: 54, alignment: .leading)

                Text(cleanVerseText(verse.text))
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(VFColors.textDark)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, VFSpacing.large)
            .padding(.vertical, VFSpacing.large)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Verse \(verse.number)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint(cleanVerseText(verse.text))
    }

    private func cleanVerseText(_ text: String) -> String {
        text.replacingOccurrences(of: "¶ ", with: "")
    }

    private var emptyVerseState: some View {
        VFEmptyStateView(
            systemName: "text.book.closed",
            title: "No verses are available for this chapter.",
            message: "Go back and choose a different chapter.",
            alignment: .leading
        )
    }

    private func errorRow(_ message: String) -> some View {
        HStack(alignment: .top, spacing: VFSpacing.medium) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(VFColors.dangerRed)

            Text(message)
                .font(VFFonts.callout)
                .foregroundStyle(VFColors.primaryNavy)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(VFSpacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(VFColors.cardBackground.opacity(0.72))
        .overlay {
            RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous)
                .stroke(VFColors.dangerRed.opacity(0.32), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
    }

    private func fetchSelectedPassage() {
        Task {
            let didFetch = await viewModel.fetchSelectedPassage()
            if didFetch {
                isShowingPreview = true
            }
        }
    }
}

struct VerseSelectionView_Previews: PreviewProvider {
    private static var previewViewModel: AddVerseViewModel {
        let viewModel = AddVerseViewModel()
        if let john = viewModel.books.first(where: { $0.name == "John" }) {
            viewModel.selectBook(john)
            viewModel.selectChapter(3)
            if let verse = viewModel.verses.first(where: { $0.number == 16 }) {
                viewModel.toggleVerse(verse)
            }
        }

        return viewModel
    }

    static var previews: some View {
        NavigationStack {
            VerseSelectionView(viewModel: previewViewModel)
        }
    }
}
