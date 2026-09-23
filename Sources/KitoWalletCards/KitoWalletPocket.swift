//
//  KitoWalletPocket.swift
//  KitoWalletCards
//
//  Created by Wycliff on 9/23/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// Colours for `KitoWalletPocket`.
public struct KitoWalletPocketStyle: Equatable, Sendable {
    public var pocket: Color
    public var foreground: Color
    public var secondaryForeground: Color
    public var stitch: Color
    /// The light that blooms behind the cards as they rise.
    public var glow: [Color]

    public init(pocket: Color, foreground: Color = .white, secondaryForeground: Color? = nil, stitch: Color? = nil, glow: [Color]) {
        self.pocket = pocket
        self.foreground = foreground
        self.secondaryForeground = secondaryForeground ?? foreground.opacity(0.6)
        self.stitch = stitch ?? foreground.opacity(0.25)
        self.glow = glow
    }

    /// Deep navy glass with a blue-violet glow.
    public static let midnight = KitoWalletPocketStyle(pocket: Color(red: 0.13, green: 0.14, blue: 0.3), glow: [Color(red: 0.45, green: 0.35, blue: 1), Color(red: 0.1, green: 0.8, blue: 1)])
    /// Slate leather with a soft blue glow.
    public static let slate = KitoWalletPocketStyle(pocket: Color(red: 0.11, green: 0.17, blue: 0.24), secondaryForeground: Color(red: 0.45, green: 0.62, blue: 0.85), glow: [Color(red: 0.4, green: 0.6, blue: 1)])
    /// Warm tan leather for light screens.
    public static let tan = KitoWalletPocketStyle(pocket: Color(red: 0.62, green: 0.42, blue: 0.26), glow: [Color(red: 1, green: 0.8, blue: 0.5)])
}

/// Cards tucked into a stitched pocket with the total hidden. Reveal it and the cards spring up
/// out of the pocket and fan, each showing its balance, while a glow blooms behind them and the
/// total counts in. Hide it and they sink back.
public struct KitoWalletPocket: View {
    let cards: [KitoWalletCard]
    @Binding var isRevealed: Bool
    let style: KitoWalletPocketStyle
    let title: String
    let showLabel: String
    let hideLabel: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(cards: [KitoWalletCard], isRevealed: Binding<Bool>, style: KitoWalletPocketStyle = .midnight,
                title: String = "Total balance", showLabel: String = "Show the balance", hideLabel: String = "Hide the balance") {
        self.cards = cards
        _isRevealed = isRevealed
        self.style = style
        self.title = title
        self.showLabel = showLabel
        self.hideLabel = hideLabel
    }

    private var currencyCode: String { cards.first?.currencyCode ?? "USD" }

    public var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let cardWidth = width * 0.84
            let cardHeight = cardWidth / KitoWalletCardGeometry.aspectRatio
            let pocketHeight = cardHeight * 1.05
            let pocketTop = geometry.size.height - pocketHeight

            ZStack(alignment: .top) {
                // Glow behind the cards.
                Ellipse()
                    .fill(RadialGradient(colors: style.glow.map { $0.opacity(0.9) } + [.clear], center: .center, startRadius: 0, endRadius: width * 0.5))
                    .frame(width: width * 1.1, height: cardHeight * 1.6)
                    .blur(radius: 30)
                    .opacity(isRevealed ? 0.85 : 0)
                    .scaleEffect(isRevealed ? 1 : 0.6)
                    .offset(y: pocketTop - cardHeight * 0.9)

                // Pocket back.
                KitoPocketShape(dip: 0)
                    .fill(style.pocket.opacity(0.55))
                    .frame(width: width, height: pocketHeight + cardHeight * 0.18)
                    .offset(y: pocketTop - cardHeight * 0.18)

                // Cards, back to front.
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    KitoWalletCardView(card: card, showsBalance: isRevealed)
                        .frame(width: cardWidth)
                        .shadow(color: .black.opacity(0.3), radius: 10, y: -2)
                        .offset(y: pocketTop + Self.cardOffset(index: index, count: cards.count, cardHeight: cardHeight, revealed: isRevealed))
                        .animation(Self.spring(reduceMotion: reduceMotion).delay(reduceMotion ? 0 : Double(cards.count - 1 - index) * 0.045), value: isRevealed)
                }

                // Pocket front, with its stitching and the total.
                ZStack(alignment: .top) {
                    KitoPocketShape(dip: 18)
                        .fill(style.pocket)
                        .shadow(color: .black.opacity(0.35), radius: 16, y: -6)
                    KitoPocketShape(dip: 18)
                        .inset(by: 9)
                        .stroke(style.stitch, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    VStack(spacing: 6) {
                        Text(title.uppercased())
                            .font(.caption.weight(.semibold))
                            .kerning(1.4)
                            .foregroundStyle(style.secondaryForeground)
                        Text(isRevealed ? cards.totalBalance.formatted(.currency(code: currencyCode).precision(.fractionLength(0))) : "••••••")
                            .font(.system(size: 40, weight: .bold, design: .rounded).monospacedDigit())
                            .foregroundStyle(style.foreground)
                            .contentTransition(.numericText(value: isRevealed ? cards.totalBalance : 0))
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                        Button {
                            isRevealed.toggle()
                        } label: {
                            Label(isRevealed ? hideLabel : showLabel, systemImage: isRevealed ? "eye.slash" : "eye")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(style.secondaryForeground)
                                .contentTransition(.symbolEffect(.replace))
                                .padding(.horizontal, 16)
                                .frame(height: 40)
                                .background(Capsule().fill(style.foreground.opacity(0.08)))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 38)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 20)
                }
                .frame(width: width, height: pocketHeight)
                .offset(y: pocketTop)
            }
            .frame(width: width, height: geometry.size.height, alignment: .top)
            .animation(Self.spring(reduceMotion: reduceMotion), value: isRevealed)
        }
        .aspectRatio(Self.aspectRatio(cardCount: cards.count), contentMode: .fit)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Wallet with \(cards.count) cards")
    }

    /// Bouncy, like cards being pulled out; plain with Reduce Motion.
    static func spring(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeInOut(duration: 0.25) : .spring(response: 0.55, dampingFraction: 0.72)
    }

    /// Width over height: tall enough for every card's strip once they've fanned out.
    static func aspectRatio(cardCount: Int) -> CGFloat {
        let cardHeight = 0.84 / KitoWalletCardGeometry.aspectRatio
        let fan = cardHeight * (0.62 + 0.2 * CGFloat(max(cardCount - 1, 0))) + 0.06
        return 1 / (cardHeight * 1.05 + fan)
    }

    /// Each card's top edge relative to the pocket's top. Hidden, they peek out in tight steps;
    /// revealed, they rise and fan so every card's top strip (mark and balance) shows. Card 0
    /// is at the back.
    static func cardOffset(index: Int, count: Int, cardHeight: CGFloat, revealed: Bool) -> CGFloat {
        let fromFront = CGFloat(count - 1 - index)
        if revealed {
            let step = cardHeight * 0.2
            return -cardHeight * 0.62 - fromFront * step
        } else {
            let step = cardHeight * 0.07
            return -cardHeight * 0.2 - fromFront * step
        }
    }
}

/// A pocket: rounded corners and a top edge that dips gently in the middle, like leather.
public struct KitoPocketShape: InsettableShape {
    var dip: CGFloat
    var cornerRadius: CGFloat = 34
    var insetAmount: CGFloat = 0

    public init(dip: CGFloat, cornerRadius: CGFloat = 34) {
        self.dip = dip
        self.cornerRadius = cornerRadius
    }

    public func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let radius = max(cornerRadius - insetAmount, 4)
        var path = Path()
        path.move(to: CGPoint(x: r.minX, y: r.minY + radius))
        path.addQuadCurve(to: CGPoint(x: r.minX + radius, y: r.minY), control: CGPoint(x: r.minX, y: r.minY))
        path.addCurve(
            to: CGPoint(x: r.maxX - radius, y: r.minY),
            control1: CGPoint(x: r.midX - r.width * 0.2, y: r.minY + dip),
            control2: CGPoint(x: r.midX + r.width * 0.2, y: r.minY + dip)
        )
        path.addQuadCurve(to: CGPoint(x: r.maxX, y: r.minY + radius), control: CGPoint(x: r.maxX, y: r.minY))
        path.addLine(to: CGPoint(x: r.maxX, y: r.maxY - radius))
        path.addQuadCurve(to: CGPoint(x: r.maxX - radius, y: r.maxY), control: CGPoint(x: r.maxX, y: r.maxY))
        path.addLine(to: CGPoint(x: r.minX + radius, y: r.maxY))
        path.addQuadCurve(to: CGPoint(x: r.minX, y: r.maxY - radius), control: CGPoint(x: r.minX, y: r.maxY))
        path.closeSubpath()
        return path
    }

    public func inset(by amount: CGFloat) -> KitoPocketShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}
