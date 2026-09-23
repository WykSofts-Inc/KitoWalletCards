//
//  KitoWalletCardView.swift
//  KitoWalletCards
//
//  Created by Wycliff on 9/23/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// A payment card face, ID-1 proportioned. Flips to its back (signature strip and CVV) with
/// `isFlipped`, and shows its balance in the corner with `showsBalance`.
public struct KitoWalletCardView: View {
    let card: KitoWalletCard
    let showsBalance: Bool
    let isFlipped: Bool
    let cvv: String?

    public init(card: KitoWalletCard, showsBalance: Bool = false, isFlipped: Bool = false, cvv: String? = nil) {
        self.card = card
        self.showsBalance = showsBalance
        self.isFlipped = isFlipped
        self.cvv = cvv
    }

    public var body: some View {
        FlipContainer(angle: isFlipped ? 180 : 0) {
            KitoWalletCardFront(card: card, showsBalance: showsBalance)
        } back: {
            KitoWalletCardBack(card: card, cvv: cvv)
        }
        .aspectRatio(KitoWalletCardGeometry.aspectRatio, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(card.name) card ending \(card.last4)\(showsBalance ? ", balance \(card.formattedBalance)" : "")")
    }
}

/// Rotates between two faces, switching at 90° so the back never shows mirrored.
struct FlipContainer<Front: View, Back: View>: View, Animatable {
    var angle: Double
    let front: Front
    let back: Back

    init(angle: Double, @ViewBuilder front: () -> Front, @ViewBuilder back: () -> Back) {
        self.angle = angle
        self.front = front()
        self.back = back()
    }

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    static func showsBack(_ angle: Double) -> Bool {
        let normalized = angle.truncatingRemainder(dividingBy: 360)
        let positive = normalized < 0 ? normalized + 360 : normalized
        return positive > 90 && positive < 270
    }

    var body: some View {
        ZStack {
            front.opacity(Self.showsBack(angle) ? 0 : 1)
            back
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(Self.showsBack(angle) ? 1 : 0)
        }
        .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), perspective: 0.45)
    }
}

// MARK: - Faces

struct KitoWalletCardFront: View {
    let card: KitoWalletCard
    let showsBalance: Bool

    var body: some View {
        GeometryReader { geometry in
            let unit = geometry.size.width / 320
            ZStack(alignment: .topLeading) {
                KitoWalletCardSurface(style: card.style)
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center) {
                        KitoWalletCardMarkView(mark: card.mark, height: 22 * unit, foreground: card.style.foreground)
                        Spacer()
                        if showsBalance {
                            Text(card.formattedBalance)
                                .font(.system(size: 15 * unit, weight: .bold, design: .rounded).monospacedDigit())
                                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        } else {
                            Text(card.name.uppercased())
                                .font(.system(size: 10 * unit, weight: .bold))
                                .kerning(1.2)
                                .opacity(0.75)
                        }
                    }
                    .frame(height: 28 * unit)
                    Spacer(minLength: 0)
                    HStack(spacing: 10 * unit) {
                        KitoWalletCardChip().frame(width: 40 * unit, height: 30 * unit)
                        Image(systemName: "wave.3.right").font(.system(size: 16 * unit, weight: .semibold)).opacity(0.8)
                    }
                    Spacer(minLength: 0)
                    Text(card.groupedMaskedNumber)
                        .font(.system(size: 19 * unit, weight: .semibold, design: .monospaced))
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 2 * unit) {
                            Text("CARD HOLDER").font(.system(size: 8 * unit, weight: .semibold)).opacity(0.6)
                            Text(card.holder).font(.system(size: 13 * unit, weight: .semibold)).lineLimit(1)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2 * unit) {
                            Text("EXPIRES").font(.system(size: 8 * unit, weight: .semibold)).opacity(0.6)
                            Text(card.expiry).font(.system(size: 13 * unit, weight: .semibold).monospacedDigit())
                        }
                    }
                }
                .padding(20 * unit)
                .foregroundStyle(card.style.foreground)
            }
            .clipShape(RoundedRectangle(cornerRadius: card.style.cornerRadius * unit, style: .continuous))
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showsBalance)
        }
    }
}

struct KitoWalletCardBack: View {
    let card: KitoWalletCard
    let cvv: String?

    var body: some View {
        GeometryReader { geometry in
            let unit = geometry.size.width / 320
            ZStack(alignment: .topLeading) {
                KitoWalletCardSurface(style: card.style)
                VStack(alignment: .leading, spacing: 14 * unit) {
                    Rectangle().fill(.black.opacity(0.85)).frame(height: 40 * unit).padding(.top, 22 * unit)
                    HStack(spacing: 10 * unit) {
                        RoundedRectangle(cornerRadius: 4 * unit)
                            .fill(.white.opacity(0.9))
                            .overlay(alignment: .leading) {
                                Text(card.holder).font(.system(size: 11 * unit, weight: .medium).italic()).foregroundStyle(.black.opacity(0.55)).padding(.leading, 8 * unit)
                            }
                            .frame(height: 32 * unit)
                        Text(cvv ?? "•••")
                            .font(.system(size: 15 * unit, weight: .bold, design: .monospaced))
                            .foregroundStyle(.black)
                            .frame(width: 54 * unit, height: 32 * unit)
                            .background(RoundedRectangle(cornerRadius: 4 * unit).fill(.white))
                    }
                    .padding(.horizontal, 20 * unit)
                    Spacer()
                    HStack {
                        Text("Authorised signature · not valid unless signed").font(.system(size: 8 * unit)).opacity(0.6)
                        Spacer()
                        KitoWalletCardMarkView(mark: card.mark, height: 16 * unit, foreground: card.style.foreground)
                    }
                    .padding([.horizontal, .bottom], 20 * unit)
                }
                .foregroundStyle(card.style.foreground)
            }
            .clipShape(RoundedRectangle(cornerRadius: card.style.cornerRadius * unit, style: .continuous))
        }
    }
}

/// The fill, pattern and border of a card.
struct KitoWalletCardSurface: View {
    let style: KitoWalletCardStyle

    var body: some View {
        ZStack {
            LinearGradient(colors: style.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            KitoWalletCardPatternView(pattern: style.pattern, color: style.foreground)
            if style.showsBorder {
                RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                    .strokeBorder(style.foreground.opacity(0.18), lineWidth: 1)
            }
        }
    }
}

struct KitoWalletCardPatternView: View {
    let pattern: KitoWalletCardPattern
    let color: Color

    var body: some View {
        Canvas { context, size in
            switch pattern {
            case .none:
                break
            case .waves:
                for index in 0..<7 {
                    let radius = size.width * (0.35 + Double(index) * 0.16)
                    let rect = CGRect(x: size.width - radius, y: size.height - radius, width: radius * 2, height: radius * 2)
                    context.stroke(Path(ellipseIn: rect), with: .color(color.opacity(0.08)), lineWidth: 1.2)
                }
            case .circles:
                context.fill(Path(ellipseIn: CGRect(x: size.width * 0.55, y: -size.height * 0.35, width: size.width * 0.75, height: size.width * 0.75)), with: .color(color.opacity(0.12)))
                context.fill(Path(ellipseIn: CGRect(x: -size.width * 0.25, y: size.height * 0.45, width: size.width * 0.6, height: size.width * 0.6)), with: .color(color.opacity(0.08)))
            case .brushed:
                var path = Path()
                var x = -size.height
                while x < size.width {
                    path.move(to: CGPoint(x: x, y: size.height))
                    path.addLine(to: CGPoint(x: x + size.height, y: 0))
                    x += 3
                }
                context.stroke(path, with: .color(color.opacity(0.05)), lineWidth: 0.6)
            case .dots:
                let step: CGFloat = 12
                for row in stride(from: step / 2, to: size.height, by: step) {
                    for column in stride(from: step / 2, to: size.width, by: step) {
                        context.fill(Path(ellipseIn: CGRect(x: column - 1, y: row - 1, width: 2, height: 2)), with: .color(color.opacity(0.1)))
                    }
                }
            case .gloss:
                var path = Path()
                path.move(to: CGPoint(x: size.width * 0.35, y: 0))
                path.addLine(to: CGPoint(x: size.width * 0.75, y: 0))
                path.addLine(to: CGPoint(x: size.width * 0.35, y: size.height))
                path.addLine(to: CGPoint(x: -size.width * 0.05, y: size.height))
                path.closeSubpath()
                context.fill(path, with: .linearGradient(Gradient(colors: [.white.opacity(0.28), .white.opacity(0)]), startPoint: CGPoint(x: size.width * 0.5, y: 0), endPoint: CGPoint(x: size.width * 0.3, y: size.height)))
            }
        }
        .allowsHitTesting(false)
    }
}

struct KitoWalletCardChip: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(LinearGradient(colors: [Color(red: 0.95, green: 0.83, blue: 0.5), Color(red: 0.78, green: 0.62, blue: 0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                GeometryReader { geometry in
                    Path { path in
                        let w = geometry.size.width, h = geometry.size.height
                        path.move(to: CGPoint(x: w * 0.33, y: 0)); path.addLine(to: CGPoint(x: w * 0.33, y: h))
                        path.move(to: CGPoint(x: w * 0.66, y: 0)); path.addLine(to: CGPoint(x: w * 0.66, y: h))
                        path.move(to: CGPoint(x: 0, y: h * 0.5)); path.addLine(to: CGPoint(x: w, y: h * 0.5))
                    }
                    .stroke(Color.black.opacity(0.18), lineWidth: 0.8)
                }
            }
    }
}

/// Draws a `KitoWalletCardMark`.
public struct KitoWalletCardMarkView: View {
    let mark: KitoWalletCardMark
    let height: CGFloat
    let foreground: Color

    public init(mark: KitoWalletCardMark, height: CGFloat = 22, foreground: Color = .white) {
        self.mark = mark
        self.height = height
        self.foreground = foreground
    }

    public var body: some View {
        switch mark {
        case .wordmark(let text, let italic):
            Text(text)
                .font(.system(size: height * 0.8, weight: .heavy, design: .rounded))
                .italic(italic)
                .foregroundStyle(foreground)
                .lineLimit(1)
        case .symbol(let name):
            Image(systemName: name).font(.system(size: height * 0.8, weight: .bold)).foregroundStyle(foreground)
        case .circles(let first, let second):
            HStack(spacing: -height * 0.4) {
                Circle().fill(first).frame(width: height, height: height)
                Circle().fill(second.opacity(0.9)).frame(width: height, height: height)
            }
        case .none:
            EmptyView()
        }
    }
}
