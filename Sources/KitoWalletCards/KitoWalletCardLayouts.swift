//
//  KitoWalletCardLayouts.swift
//  KitoWalletCards
//
//  Created by Wycliff on 9/23/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

private func cardSpring(_ reduceMotion: Bool) -> Animation {
    reduceMotion ? .easeInOut(duration: 0.25) : .spring(response: 0.5, dampingFraction: 0.8)
}

// MARK: - Stack

/// A wallet-style stack: cards overlap so each one's top strip shows. Tap one and it slides to
/// the top while the rest tuck into a pile at the bottom; tap it again, or drag it down, to put
/// it back.
public struct KitoWalletCardStack<Detail: View>: View {
    let cards: [KitoWalletCard]
    @Binding var selection: KitoWalletCard.ID?
    let peek: CGFloat
    let detail: (KitoWalletCard) -> Detail

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dragOffset: CGFloat = 0

    /// - Parameters:
    ///   - peek: How much of each card shows in the stack.
    ///   - detail: Shown under the selected card, e.g. its recent transactions.
    public init(cards: [KitoWalletCard], selection: Binding<KitoWalletCard.ID?>, peek: CGFloat = 58,
                @ViewBuilder detail: @escaping (KitoWalletCard) -> Detail) {
        self.cards = cards
        _selection = selection
        self.peek = peek
        self.detail = detail
    }

    public var body: some View {
        GeometryReader { geometry in
            let cardHeight = geometry.size.width / KitoWalletCardGeometry.aspectRatio
            ZStack(alignment: .top) {
                if let selected = cards.first(where: { $0.id == selection }) {
                    detail(selected)
                        .frame(width: geometry.size.width)
                        .offset(y: cardHeight + 20)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    let isSelected = card.id == selection
                    KitoWalletCardView(card: card, showsBalance: isSelected)
                        .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
                        .offset(y: Self.offset(index: index, selectedIndex: cards.firstIndex { $0.id == selection }, count: cards.count,
                                               peek: peek, cardHeight: cardHeight, containerHeight: geometry.size.height)
                                + (isSelected ? max(dragOffset, 0) : 0))
                        .scaleEffect(selection != nil && !isSelected ? 0.94 : 1, anchor: .top)
                        .zIndex(Double(index))
                        .onTapGesture {
                            withAnimation(cardSpring(reduceMotion)) { selection = isSelected ? nil : card.id }
                        }
                        .gesture(dragToDismiss, including: isSelected ? .all : .none)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityHint(isSelected ? "Returns the card to the stack" : "Brings the card to the top")
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
        }
    }

    private var dragToDismiss: some Gesture {
        DragGesture()
            .onChanged { dragOffset = $0.translation.height }
            .onEnded { drag in
                withAnimation(cardSpring(reduceMotion)) {
                    if drag.translation.height > 90 { selection = nil }
                    dragOffset = 0
                }
            }
    }

    /// Stacked: `index * peek`. With a selection: the selected card at the top, the others in a
    /// tight pile at the bottom of the container.
    static func offset(index: Int, selectedIndex: Int?, count: Int, peek: CGFloat, cardHeight: CGFloat, containerHeight: CGFloat) -> CGFloat {
        guard let selectedIndex else { return CGFloat(index) * peek }
        if index == selectedIndex { return 0 }
        let pileIndex = index < selectedIndex ? index : index - 1
        let pileTop = containerHeight - cardHeight * 0.32 - CGFloat(max(count - 2, 0)) * 8
        return pileTop + CGFloat(pileIndex) * 8
    }
}

public extension KitoWalletCardStack where Detail == EmptyView {
    init(cards: [KitoWalletCard], selection: Binding<KitoWalletCard.ID?>, peek: CGFloat = 58) {
        self.init(cards: cards, selection: selection, peek: peek) { _ in EmptyView() }
    }
}

// MARK: - Carousel

/// Cards side by side; the centred one is full size, its neighbours turn away and shrink as
/// they scroll off.
public struct KitoWalletCardCarousel: View {
    let cards: [KitoWalletCard]
    @Binding var selection: KitoWalletCard.ID?
    let showsBalance: Bool

    public init(cards: [KitoWalletCard], selection: Binding<KitoWalletCard.ID?>, showsBalance: Bool = true) {
        self.cards = cards
        _selection = selection
        self.showsBalance = showsBalance
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 14) {
                ForEach(cards) { card in
                    KitoWalletCardView(card: card, showsBalance: showsBalance)
                        .shadow(color: .black.opacity(0.22), radius: 14, y: 8)
                        .containerRelativeFrame(.horizontal) { width, _ in width * 0.8 }
                        .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                            view
                                .scaleEffect(1 - min(abs(phase.value), 1) * 0.12)
                                .rotation3DEffect(.degrees(phase.value * -22), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
                                .opacity(1 - min(abs(phase.value), 1) * 0.35)
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, 36, for: .scrollContent)
        .scrollPosition(id: $selection)
    }
}

// MARK: - Fan

/// Cards fanned from a point below them, like a hand of cards. Tap one to lift it out.
public struct KitoWalletCardFan: View {
    let cards: [KitoWalletCard]
    @Binding var selection: KitoWalletCard.ID?
    let spread: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameter spread: Degrees between neighbouring cards.
    public init(cards: [KitoWalletCard], selection: Binding<KitoWalletCard.ID?>, spread: Double = 9) {
        self.cards = cards
        _selection = selection
        self.spread = spread
    }

    public var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width * 0.7
            ZStack {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    let isSelected = card.id == selection
                    KitoWalletCardView(card: card, showsBalance: isSelected)
                        .frame(width: cardWidth)
                        .shadow(color: .black.opacity(0.22), radius: 10, y: 6)
                        .rotationEffect(.degrees(isSelected ? 0 : Self.angle(index: index, count: cards.count, spread: spread)), anchor: UnitPoint(x: 0.5, y: 2.4))
                        .offset(y: isSelected ? -cardWidth * 0.32 : 0)
                        .scaleEffect(isSelected ? 1.06 : 1)
                        .zIndex(isSelected ? 100 : Double(index))
                        .onTapGesture {
                            withAnimation(cardSpring(reduceMotion)) { selection = isSelected ? nil : card.id }
                        }
                        .accessibilityAddTraits(.isButton)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .offset(y: geometry.size.height * 0.12)
        }
    }

    /// Centred on zero: with five cards and 9° spread, −18, −9, 0, 9, 18.
    static func angle(index: Int, count: Int, spread: Double) -> Double {
        (Double(index) - Double(count - 1) / 2) * spread
    }
}

// MARK: - Deck

/// A deck to thumb through: swipe the top card away and it tucks in at the back.
public struct KitoWalletCardDeck: View {
    @State private var order: [KitoWalletCard]
    @State private var drag: CGSize = .zero
    let onChange: (KitoWalletCard) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(cards: [KitoWalletCard], onChange: @escaping (KitoWalletCard) -> Void = { _ in }) {
        _order = State(initialValue: cards)
        self.onChange = onChange
    }

    public var body: some View {
        ZStack {
            ForEach(Array(order.enumerated().reversed()), id: \.element.id) { depth, card in
                KitoWalletCardView(card: card, showsBalance: depth == 0)
                    .shadow(color: .black.opacity(0.2), radius: 12, y: 8)
                    .scaleEffect(1 - CGFloat(min(depth, 3)) * 0.05)
                    .offset(y: CGFloat(min(depth, 3)) * -18)
                    .offset(depth == 0 ? drag : .zero)
                    .rotationEffect(.degrees(depth == 0 ? Double(drag.width) / 18 : 0))
                    .opacity(depth > 3 ? 0 : 1)
                    .gesture(swipe, including: depth == 0 ? .all : .none)
            }
        }
        .padding(.top, 60)
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: "Next card") { advance() }
    }

    private var swipe: some Gesture {
        DragGesture()
            .onChanged { drag = $0.translation }
            .onEnded { value in
                if abs(value.translation.width) > 100 || abs(value.predictedEndTranslation.width) > 240 {
                    withAnimation(cardSpring(reduceMotion)) {
                        drag = CGSize(width: value.translation.width > 0 ? 500 : -500, height: value.translation.height)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                        drag = .zero
                        advance()
                    }
                } else {
                    withAnimation(cardSpring(reduceMotion)) { drag = .zero }
                }
            }
    }

    private func advance() {
        guard !order.isEmpty else { return }
        withAnimation(cardSpring(reduceMotion)) {
            order.append(order.removeFirst())
        }
        if let top = order.first { onChange(top) }
    }
}

// MARK: - Tilt

public extension View {
    /// Tilts the view toward your finger in 3D, with a moving highlight like light on foil.
    func kitoCardTilt(maxAngle: Double = 14) -> some View {
        modifier(KitoCardTilt(maxAngle: maxAngle))
    }
}

struct KitoCardTilt: ViewModifier {
    let maxAngle: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var tilt: CGSize = .zero
    @State private var size: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(
                    colors: [.white.opacity(0), .white.opacity(0.35), .white.opacity(0)],
                    startPoint: UnitPoint(x: 0.5 + tilt.width * 0.6 - 0.4, y: 0),
                    endPoint: UnitPoint(x: 0.5 + tilt.width * 0.6 + 0.4, y: 1)
                )
                .blendMode(.overlay)
                .opacity(tilt == .zero ? 0 : 1)
                .allowsHitTesting(false)
            }
            .rotation3DEffect(.degrees(Double(-tilt.height) * maxAngle), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
            .rotation3DEffect(.degrees(Double(tilt.width) * maxAngle), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
            .background(GeometryReader { geometry in Color.clear.onAppear { size = geometry.size } })
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard !reduceMotion, size.width > 0, size.height > 0 else { return }
                        let x = (value.location.x / size.width - 0.5) * 2
                        let y = (value.location.y / size.height - 0.5) * 2
                        withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.8)) {
                            tilt = CGSize(width: min(max(x, -1), 1), height: min(max(y, -1), 1))
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { tilt = .zero }
                    }
            )
    }
}
