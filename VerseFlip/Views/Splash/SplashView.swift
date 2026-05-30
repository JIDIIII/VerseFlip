//
//  SplashView.swift
//  VerseFlip
//
//  Created by Codex on 5/29/26.
//

import SwiftUI

struct SplashView: View {
    var onGetStarted: () -> Void = {}

    var body: some View {
        ZStack {
            SplashBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 104)

                VStack(spacing: VFSpacing.xLarge) {
                    SplashLogoMark()

                    VStack(spacing: VFSpacing.medium) {
                        Text("VerseFlip")
                            .font(.system(size: 52, weight: .bold, design: .serif))
                            .foregroundStyle(VFColors.primaryNavy)
                            .shadow(color: VFColors.splashHighlight.opacity(0.75), radius: 1, x: 0, y: 1)

                        Text("Memorize Scripture, one card at a time.")
                            .font(.system(size: 18, weight: .regular))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(VFColors.primaryNavy)

                        HStack(spacing: VFSpacing.large) {
                            Rectangle()
                                .fill(VFColors.softGold.opacity(0.45))
                                .frame(width: 86, height: 1)

                            Image(systemName: "sparkle")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(VFColors.softGold)

                            Rectangle()
                                .fill(VFColors.softGold.opacity(0.45))
                                .frame(width: 86, height: 1)
                        }
                        .padding(.top, VFSpacing.large)

                        Text("Flip. Review. Remember.")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(VFColors.primaryNavy)
                            .padding(.top, VFSpacing.small)
                    }
                }

                Spacer()
                    .frame(minHeight: 120)

                SplashHorizon()
                    .frame(height: 210)
                    .padding(.horizontal, -VFSpacing.xLarge)
                    .overlay(alignment: .bottom) {
                        VFPrimaryButton(title: "Get Started", systemImage: "play.fill") {
                            onGetStarted()
                        }
                        .padding(.horizontal, VFSpacing.xLarge)
                        .padding(.bottom, VFSpacing.large)
                    }
            }
            .padding(.horizontal, VFSpacing.xLarge)
        }
    }
}

private struct SplashLogoMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(VFColors.softGold, lineWidth: 5)
                .frame(width: 82, height: 104)
                .overlay(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(VFColors.softGold, lineWidth: 5)
                        .frame(width: 58, height: 22)
                        .background(VFColors.warmCream)
                        .offset(x: 0, y: 1)
                }

            Image(systemName: "cross")
                .font(.system(size: 38, weight: .bold))
                .foregroundStyle(VFColors.softGold)
                .offset(y: -10)

            Image(systemName: "arrow.right")
                .font(.system(size: 44, weight: .heavy))
                .foregroundStyle(VFColors.softGold)
                .offset(x: 42, y: 44)
        }
        .frame(width: 130, height: 128)
    }
}

struct SplashBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                VFColors.splashHighlight,
                VFColors.warmCream.opacity(0.92),
                VFColors.warmCream
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

private struct SplashHorizon: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [
                    .clear,
                    VFColors.softGold.opacity(0.10),
                    VFColors.primaryNavy.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            MountainRange()
                .fill(VFColors.primaryNavy.opacity(0.05))
                .frame(height: 128)

            MountainRange()
                .fill(VFColors.softGold.opacity(0.09))
                .frame(height: 96)
                .offset(y: 12)

            CrossOnHill()
                .frame(width: 120, height: 120)
                .offset(x: 108, y: -38)
        }
        .clipped()
    }
}

private struct MountainRange: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY * 0.62))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.28, y: rect.maxY * 0.50),
            control1: CGPoint(x: rect.width * 0.08, y: rect.maxY * 0.45),
            control2: CGPoint(x: rect.width * 0.17, y: rect.maxY * 0.72)
        )
        path.addCurve(
            to: CGPoint(x: rect.width * 0.55, y: rect.maxY * 0.66),
            control1: CGPoint(x: rect.width * 0.37, y: rect.maxY * 0.30),
            control2: CGPoint(x: rect.width * 0.45, y: rect.maxY * 0.88)
        )
        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.maxY * 0.42),
            control1: CGPoint(x: rect.width * 0.70, y: rect.maxY * 0.30),
            control2: CGPoint(x: rect.width * 0.82, y: rect.maxY * 0.68)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct CrossOnHill: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [VFColors.softGold.opacity(0.18), .clear],
                        center: .center,
                        startRadius: 4,
                        endRadius: 58
                    )
                )

            Image(systemName: "cross.fill")
                .font(.system(size: 58, weight: .regular))
                .foregroundStyle(VFColors.softGold.opacity(0.58))
                .offset(y: -8)
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
