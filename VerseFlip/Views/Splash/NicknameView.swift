//
//  NicknameView.swift
//  VerseFlip
//
//  Created by Codex on 5/30/26.
//

import SwiftUI

struct NicknameView: View {
    @AppStorage("userNickname") private var storedNickname = ""

    var onComplete: () -> Void

    @State private var nickname = ""
    @State private var didTryToContinue = false

    private var trimmedNickname: String {
        nickname.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var nicknameBinding: Binding<String> {
        Binding(
            get: { nickname },
            set: { nickname = String($0.prefix(20)) }
        )
    }

    var body: some View {
        ZStack {
            SplashBackground()
                .ignoresSafeArea()

            VStack(spacing: VFSpacing.xLarge) {
                Spacer()

                SplashLogoBadge()

                VStack(spacing: VFSpacing.small) {
                    Text("What should we call you?")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)
                        .multilineTextAlignment(.center)

                    Text("Enter a nickname for your home greeting.")
                        .font(VFFonts.body)
                        .foregroundStyle(VFColors.textMuted)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: VFSpacing.small) {
                    TextField("Nickname", text: nicknameBinding)
                        .font(VFFonts.body)
                        .foregroundStyle(VFColors.textDark)
                        .padding(.horizontal, VFSpacing.large)
                        .frame(height: 56)
                        .background(VFColors.cardBackground)
                        .overlay {
                            RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous)
                                .stroke(didTryToContinue && trimmedNickname.isEmpty ? VFColors.dangerRed : VFColors.softBorder, lineWidth: 1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: VFSpacing.controlCornerRadius, style: .continuous))

                    if didTryToContinue && trimmedNickname.isEmpty {
                        Text("Nickname cannot be empty.")
                            .font(VFFonts.footnote)
                            .foregroundStyle(VFColors.dangerRed)
                    }
                }

                VFPrimaryButton(title: "Continue", systemImage: "arrow.right") {
                    saveNickname()
                }

                Spacer()
            }
            .padding(.horizontal, VFSpacing.xLarge)
        }
    }

    private func saveNickname() {
        didTryToContinue = true
        guard trimmedNickname.isEmpty == false else {
            return
        }

        storedNickname = String(trimmedNickname.prefix(20))
        onComplete()
    }
}

private struct SplashLogoBadge: View {
    var body: some View {
        Image(systemName: "person.crop.circle.badge.checkmark")
            .font(.system(size: 62, weight: .semibold))
            .foregroundStyle(VFColors.softGold)
            .frame(width: 118, height: 118)
            .background(VFColors.cardBackground.opacity(0.72))
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(VFColors.softGold.opacity(0.85), lineWidth: 1.2)
            }
    }
}

struct NicknameView_Previews: PreviewProvider {
    static var previews: some View {
        NicknameView {}
    }
}
