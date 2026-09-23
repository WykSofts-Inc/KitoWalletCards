//
//  KitoWalletCard.swift
//  KitoWalletCards
//
//  Created by Wycliff on 9/23/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// The issuer or network mark in a card's corner. Drawn, not bundled: bring your own brand by
/// passing its wordmark, a symbol, or a pair of overlapping circles.
public enum KitoWalletCardMark: Equatable, Sendable {
    case wordmark(String, italic: Bool = false)
    case symbol(String)
    case circles(Color, Color)
    case none
}

/// A background texture on the card face.
public enum KitoWalletCardPattern: Equatable, Sendable {
    case none
    /// Soft concentric waves from a corner.
    case waves
    /// Large translucent circles.
    case circles
    /// A fine diagonal line texture, like brushed metal.
    case brushed
    /// A dot grid.
    case dots
    /// A glossy diagonal sheen.
    case gloss
}

/// How a card looks: its fill, text colour, texture and corners.
public struct KitoWalletCardStyle: Equatable, Sendable {
    public var colors: [Color]
    public var foreground: Color
    public var pattern: KitoWalletCardPattern
    public var cornerRadius: CGFloat
    /// A thin inner border, for dark or glass cards.
    public var showsBorder: Bool

    public init(colors: [Color], foreground: Color = .white, pattern: KitoWalletCardPattern = .none, cornerRadius: CGFloat = 20, showsBorder: Bool = false) {
        self.colors = colors
        self.foreground = foreground
        self.pattern = pattern
        self.cornerRadius = cornerRadius
        self.showsBorder = showsBorder
    }

    public static let ocean = KitoWalletCardStyle(colors: [Color(red: 0.1, green: 0.45, blue: 0.95), Color(red: 0.1, green: 0.75, blue: 0.95)], pattern: .waves)
    public static let sunset = KitoWalletCardStyle(colors: [Color(red: 1, green: 0.55, blue: 0.2), Color(red: 0.95, green: 0.25, blue: 0.5)], pattern: .circles)
    public static let aqua = KitoWalletCardStyle(colors: [Color(red: 0.1, green: 0.75, blue: 0.85), Color(red: 0.15, green: 0.55, blue: 0.95)], pattern: .gloss)
    public static let midnight = KitoWalletCardStyle(colors: [Color(white: 0.12), Color(white: 0.02)], pattern: .brushed, showsBorder: true)
    public static let lavender = KitoWalletCardStyle(colors: [Color(red: 0.72, green: 0.68, blue: 0.98), Color(red: 0.6, green: 0.55, blue: 0.95)], foreground: .black, pattern: .none)
    public static let lime = KitoWalletCardStyle(colors: [Color(red: 0.78, green: 0.95, blue: 0.45), Color(red: 0.62, green: 0.88, blue: 0.3)], foreground: .black, pattern: .dots)
    public static let pearl = KitoWalletCardStyle(colors: [Color(white: 0.96), Color(white: 0.86)], foreground: .black, pattern: .gloss)
    public static let gold = KitoWalletCardStyle(colors: [Color(red: 0.95, green: 0.8, blue: 0.45), Color(red: 0.75, green: 0.55, blue: 0.2)], foreground: Color(red: 0.25, green: 0.18, blue: 0.05), pattern: .brushed)
}

public struct KitoWalletCard: Identifiable, Equatable, Sendable {
    public var id: String
    /// What the card is for: "Everyday", "Savings", "Travel".
    public var name: String
    public var mark: KitoWalletCardMark
    public var last4: String
    public var holder: String
    /// "MM/YY".
    public var expiry: String
    public var balance: Double
    public var currencyCode: String
    public var style: KitoWalletCardStyle

    public init(id: String = UUID().uuidString, name: String, mark: KitoWalletCardMark, last4: String, holder: String, expiry: String,
                balance: Double, currencyCode: String = "USD", style: KitoWalletCardStyle) {
        self.id = id
        self.name = name
        self.mark = mark
        self.last4 = last4
        self.holder = holder
        self.expiry = expiry
        self.balance = balance
        self.currencyCode = currencyCode
        self.style = style
    }

    public var formattedBalance: String {
        balance.formatted(.currency(code: currencyCode).precision(.fractionLength(0)))
    }

    /// "•••• 4120".
    public var maskedNumber: String { "•••• \(last4)" }

    /// "•••• •••• •••• 4120". Cards only ever hold the last four digits.
    public var groupedMaskedNumber: String { "•••• •••• •••• \(last4)" }
}

public extension Array where Element == KitoWalletCard {
    /// The sum of the balances. Mixed currencies are summed as-is; convert first if they differ.
    var totalBalance: Double { reduce(0) { $0 + $1.balance } }
}

/// Card faces are ID-1 sized: 85.6 × 53.98 mm.
public enum KitoWalletCardGeometry {
    public static let aspectRatio: CGFloat = 85.6 / 53.98
}
