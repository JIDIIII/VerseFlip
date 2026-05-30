//
//  TodayVerseCardView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct TodayVerseCardView: View {
    let reference: String
    let verseText: String

    var body: some View {
        VFCard(padding: 0) {
            ZStack(alignment: .bottomTrailing) {
                VerseCardLandscape()
                    .frame(width: 172, height: 136)
                    .opacity(0.92)
                    .offset(x: 16, y: 10)

                VStack(alignment: .leading, spacing: VFSpacing.medium) {
                    HStack(alignment: .firstTextBaseline, spacing: VFSpacing.small) {
                        Text("\"")
                            .font(.system(size: 42, weight: .bold, design: .serif))
                            .foregroundStyle(VFColors.softGold)
                            .offset(y: 7)

                        Text("Verse of the Day")
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .foregroundStyle(VFColors.primaryNavy)
                    }

                    Text(verseText)
                        .font(.system(size: 16, weight: .regular))
                        .lineSpacing(4)
                        .foregroundStyle(VFColors.textDark)
                        .padding(.trailing, 98)

                    Text(reference)
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .foregroundStyle(VFColors.primaryNavy)
                }
                .padding(VFSpacing.large)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private struct VerseCardLandscape: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [
                    .clear,
                    VFColors.softGold.opacity(0.18),
                    VFColors.primaryNavy.opacity(0.07)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LandscapeMountain()
                .fill(VFColors.primaryNavy.opacity(0.09))
                .frame(height: 68)

            LandscapeMountain()
                .fill(VFColors.softGold.opacity(0.14))
                .frame(height: 52)
                .offset(y: 8)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [VFColors.softGold.opacity(0.20), .clear],
                        center: .center,
                        startRadius: 2,
                        endRadius: 52
                    )
                )
                .frame(width: 104, height: 104)
                .offset(x: 34, y: -28)

            Image(systemName: "cross.fill")
                .font(.system(size: 45, weight: .regular))
                .foregroundStyle(VFColors.softGold.opacity(0.62))
                .offset(x: 38, y: -28)
        }
        .clipShape(RoundedRectangle(cornerRadius: VFSpacing.cardCornerRadius, style: .continuous))
    }
}

private struct LandscapeMountain: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY * 0.70))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.34, y: rect.maxY * 0.48),
            control1: CGPoint(x: rect.width * 0.10, y: rect.maxY * 0.52),
            control2: CGPoint(x: rect.width * 0.22, y: rect.maxY * 0.84)
        )
        path.addCurve(
            to: CGPoint(x: rect.width * 0.58, y: rect.maxY * 0.68),
            control1: CGPoint(x: rect.width * 0.42, y: rect.maxY * 0.30),
            control2: CGPoint(x: rect.width * 0.48, y: rect.maxY * 0.86)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY * 0.44),
            control1: CGPoint(x: rect.width * 0.72, y: rect.maxY * 0.36),
            control2: CGPoint(x: rect.width * 0.86, y: rect.maxY * 0.58)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct TodayVerseCardView_Previews: PreviewProvider {
    static var previews: some View {
        TodayVerseCardView(
            reference: "John 3:16 NIV",
            verseText: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life."
        )
        .padding()
        .background(VFColors.warmCream)
    }
}
