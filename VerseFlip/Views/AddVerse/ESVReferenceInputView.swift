//
//  ESVReferenceInputView.swift
//  VerseFlip
//
//  Created by Codex on 5/30/26.
//

import SwiftUI

struct ESVReferenceInputView: View {
    @ObservedObject var viewModel: AddVerseViewModel
    @FocusState private var isReferenceFieldFocused: Bool
    @State private var isShowingPreview = false

    private let exampleReferences = [
        "John 3:16",
        "Psalm 23:1",
        "Romans 8:28",
        "Philippians 4:6-7"
    ]

    var body: some View {
        ZStack {
            VFColors.warmCream
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VFSpacing.xLarge) {
                    AddVerseTopBar(title: "Add \(selectedVersionLabel) Verse")

                    header
                    referenceField
                    exampleChips

                    if let errorMessage = viewModel.passageFetchErrorMessage {
                        errorRow(errorMessage)
                    }

                    fetchButton
                }
                .padding(.horizontal, VFSpacing.xLarge)
                .padding(.top, VFSpacing.large)
                .padding(.bottom, VFSpacing.xxLarge)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            isReferenceFieldFocused = true
        }
        .navigationDestination(isPresented: $isShowingPreview) {
            VersePreviewView(viewModel: viewModel)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: VFSpacing.medium) {
            HStack(spacing: VFSpacing.medium) {
                Image(systemName: "network")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(VFColors.softGold)

                Text("Enter Reference")
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundStyle(VFColors.primaryNavy)
            }

            Text("Enter a Bible reference to fetch from the \(selectedVersionLabel) API.")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(VFColors.textMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var referenceField: some View {
        TextField("John 3:16", text: $viewModel.referenceInput)
            .font(.system(size: 22, weight: .bold, design: .serif))
            .foregroundStyle(VFColors.primaryNavy)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .submitLabel(.go)
            .focused($isReferenceFieldFocused)
            .padding(.horizontal, VFSpacing.large)
            .frame(height: 64)
            .background(VFColors.cardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous)
                    .stroke(VFColors.softBorder, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
            .onSubmit {
                fetchReference()
            }
            .accessibilityLabel("\(selectedVersionLabel) Bible reference")
    }

    private var exampleChips: some View {
        VStack(alignment: .leading, spacing: VFSpacing.medium) {
            Text("Examples")
                .font(VFFonts.callout)
                .foregroundStyle(VFColors.textMuted)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 132), spacing: VFSpacing.small)],
                alignment: .leading,
                spacing: VFSpacing.small
            ) {
                ForEach(exampleReferences, id: \.self) { reference in
                    Button {
                        viewModel.referenceInput = reference
                        viewModel.clearPassageFetchError()
                    } label: {
                        Text(reference)
                            .font(VFFonts.chip)
                            .foregroundStyle(VFColors.primaryNavy)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, VFSpacing.medium)
                            .frame(height: 38)
                            .background(VFColors.cardBackground)
                            .overlay {
                                Capsule()
                                    .stroke(VFColors.softGold.opacity(0.7), lineWidth: 1)
                            }
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var fetchButton: some View {
        Button {
            fetchReference()
        } label: {
            HStack(spacing: VFSpacing.small) {
                if viewModel.isFetchingPassage {
                    ProgressView()
                        .tint(VFColors.cardBackground)
                } else {
                    Image(systemName: "arrow.down.doc")
                        .font(.system(size: 18, weight: .bold))
                }

                Text(viewModel.isFetchingPassage ? "Fetching..." : "Fetch Verse")
                    .font(VFFonts.button)
            }
            .foregroundStyle(VFColors.cardBackground)
            .frame(maxWidth: .infinity)
            .frame(height: VFSpacing.buttonHeight)
            .background(viewModel.isFetchingPassage ? VFColors.textMuted : VFColors.primaryNavy)
            .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))
            .shadow(color: VFColors.shadow, radius: VFSpacing.controlShadowRadius, x: 0, y: VFSpacing.controlShadowYOffset)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isFetchingPassage)
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

    private func fetchReference() {
        Task {
            let didFetch = await viewModel.fetchReference()
            if didFetch {
                isReferenceFieldFocused = false
                isShowingPreview = true
            }
        }
    }

    private var selectedVersionLabel: String {
        viewModel.selectedVersion?.rawValue ?? "Bible"
    }
}

struct ESVReferenceInputView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ESVReferenceInputView(viewModel: AddVerseViewModel())
        }
    }
}
