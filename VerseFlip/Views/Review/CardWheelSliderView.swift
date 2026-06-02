//
//  CardWheelSliderView.swift
//  VerseFlip
//
//  Created by Codex on 6/2/26.
//

import SwiftUI

struct CardWheelSliderView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let items: [PreloadedReviewCard]
    let selectedIndex: Int
    let totalCount: Int
    let isShowingVerse: Bool
    let maxCardHeight: CGFloat
    let onTap: () -> Void
    let onSelectIndex: (Int) -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let cardWidth = cardWidth(in: proxy.size.width)
            let wheelSpacing = wheelSpacing(for: cardWidth)

            ZStack {
                ForEach(items) { item in
                    let position = wheelPosition(for: item.index, spacing: wheelSpacing)
                    let isSelected = item.index == selectedIndex

                    FlipCardView(
                        card: item.card,
                        isShowingVerse: isSelected ? isShowingVerse : false,
                        maxCardHeight: maxCardHeight,
                        onTap: isSelected ? onTap : {}
                    )
                    .frame(width: cardWidth)
                    .modifier(CardWheelItemStyle(position: position, spacing: wheelSpacing, reduceMotion: reduceMotion))
                    .zIndex(zIndex(for: position))
                    .allowsHitTesting(isSelected)
                    .accessibilityHidden(isSelected == false)
                    .accessibilityAction(named: "Previous card") {
                        selectIndex(selectedIndex - 1)
                    }
                    .accessibilityAction(named: "Next card") {
                        selectIndex(selectedIndex + 1)
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .contentShape(Rectangle())
            .gesture(totalCount > 1 ? dragGesture(spacing: wheelSpacing) : nil)
        }
        .frame(maxWidth: .infinity)
        .frame(height: maxCardHeight + VFSpacing.xxLarge)
        .animation(wheelAnimation, value: selectedIndex)
        .animation(wheelAnimation, value: dragOffset)
        .onChange(of: selectedIndex) { _ in
            dragOffset = 0
        }
    }

    private var wheelAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.12)
            : .spring(response: 0.36, dampingFraction: 0.86)
    }

    private func dragGesture(spacing: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 18, coordinateSpace: .local)
            .onChanged { value in
                guard abs(value.translation.width) > abs(value.translation.height) else {
                    return
                }

                dragOffset = constrainedDragOffset(value.translation.width)
            }
            .onEnded { value in
                let horizontalDistance = value.predictedEndTranslation.width
                let isHorizontalSwipe = abs(value.translation.width) > abs(value.translation.height)

                guard isHorizontalSwipe else {
                    resetDrag()
                    return
                }

                let rawStep = -horizontalDistance / max(spacing, 1)
                let roundedStep = Int(rawStep.rounded())
                let minimumStep = abs(value.translation.width) > 28 ? (value.translation.width < 0 ? 1 : -1) : 0
                let proposedStep = roundedStep == 0 ? minimumStep : roundedStep
                let targetIndex = clampedIndex(selectedIndex + limitedStep(proposedStep))

                withAnimation(wheelAnimation) {
                    dragOffset = 0
                    if targetIndex != selectedIndex {
                        onSelectIndex(targetIndex)
                    }
                }
            }
    }

    private func cardWidth(in availableWidth: CGFloat) -> CGFloat {
        min(max(availableWidth * 0.82, 260), 360)
    }

    private func wheelSpacing(for cardWidth: CGFloat) -> CGFloat {
        cardWidth * 0.72
    }

    private func wheelPosition(for index: Int, spacing: CGFloat) -> CGFloat {
        CGFloat(index - selectedIndex) + dragOffset / max(spacing, 1)
    }

    private func constrainedDragOffset(_ offset: CGFloat) -> CGFloat {
        if offset > 0, selectedIndex == 0 {
            return offset * 0.28
        }

        if offset < 0, selectedIndex >= totalCount - 1 {
            return offset * 0.28
        }

        return offset
    }

    private func limitedStep(_ step: Int) -> Int {
        min(max(step, -3), 3)
    }

    private func clampedIndex(_ index: Int) -> Int {
        min(max(index, 0), max(totalCount - 1, 0))
    }

    private func selectIndex(_ index: Int) {
        let targetIndex = clampedIndex(index)
        guard targetIndex != selectedIndex else {
            return
        }

        withAnimation(wheelAnimation) {
            onSelectIndex(targetIndex)
        }
    }

    private func resetDrag() {
        withAnimation(wheelAnimation) {
            dragOffset = 0
        }
    }

    private func zIndex(for position: CGFloat) -> Double {
        Double(100 - min(abs(position), 10))
    }
}

private struct CardWheelItemStyle: ViewModifier {
    let position: CGFloat
    let spacing: CGFloat
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        let distance = abs(position)
        let scale = reduceMotion ? 1 : max(0.82, 1 - min(distance, 3) * 0.075)
        let opacity = max(0.18, 1 - min(distance, 3.5) * 0.22)
        let yOffset = reduceMotion ? 0 : min(distance, 3) * 18
        let rotation = reduceMotion ? 0 : min(8, distance * 4) * (position < 0 ? 1 : -1)
        let perspectiveRotation = reduceMotion ? 0 : min(28, abs(position) * 13) * (position < 0 ? 1 : -1)

        content
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(x: position * spacing, y: yOffset)
            .rotationEffect(.degrees(rotation))
            .rotation3DEffect(
                .degrees(perspectiveRotation),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.78
            )
            .shadow(
                color: VFColors.shadow.opacity(distance < 0.5 ? 1 : 0.35),
                radius: distance < 0.5 ? VFSpacing.cardShadowRadius : 6,
                x: 0,
                y: distance < 0.5 ? VFSpacing.cardShadowYOffset : 4
            )
    }
}

struct CardWheelSliderView_Previews: PreviewProvider {
    static var previews: some View {
        CardWheelSliderView(
            items: [
                PreloadedReviewCard(
                    index: 0,
                    card: VerseCard(
                        verseText: "For God so loved the world that he gave his only begotten Son.",
                        reference: "John 3:16",
                        book: "John",
                        chapter: 3,
                        verseStart: 16
                    )
                ),
                PreloadedReviewCard(
                    index: 1,
                    card: VerseCard(
                        verseText: "The Lord is my shepherd; I shall not want.",
                        reference: "Psalm 23:1",
                        book: "Psalms",
                        chapter: 23,
                        verseStart: 1
                    )
                )
            ],
            selectedIndex: 0,
            totalCount: 2,
            isShowingVerse: false,
            maxCardHeight: 360
        ) {} onSelectIndex: { _ in }
            .padding()
            .background(VFColors.warmCream)
    }
}
