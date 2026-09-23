//
//  KitoWalletCardsTests.swift
//  KitoWalletCards
//
//  Created by Wycliff on 9/23/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import XCTest
import SwiftUI
@testable import KitoWalletCards

final class KitoWalletCardsTests: XCTestCase {
    private func cards(_ balances: [Double]) -> [KitoWalletCard] {
        balances.enumerated().map { index, balance in
            KitoWalletCard(id: "\(index)", name: "Card \(index)", mark: .wordmark("NOVA"), last4: "412\(index)", holder: "Wycliff N", expiry: "09/29", balance: balance, style: .ocean)
        }
    }

    // MARK: Model

    func testTheTotalAddsEveryBalance() {
        XCTAssertEqual(cards([27_485, 65_324, 413_176]).totalBalance, 505_985)
        XCTAssertEqual([KitoWalletCard]().totalBalance, 0)
    }

    func testNumbersAreAlwaysMasked() {
        let card = cards([1])[0]
        XCTAssertEqual(card.maskedNumber, "•••• 4120")
        XCTAssertEqual(card.groupedMaskedNumber, "•••• •••• •••• 4120")
    }

    func testCardsKeepIDOneProportions() {
        XCTAssertEqual(KitoWalletCardGeometry.aspectRatio, 1.5858, accuracy: 0.001)
    }

    // MARK: Flip

    func testTheBackShowsOnlyBetweenNinetyAndTwoSeventyDegrees() {
        XCTAssertFalse(FlipContainer<EmptyView, EmptyView>.showsBack(0))
        XCTAssertFalse(FlipContainer<EmptyView, EmptyView>.showsBack(89))
        XCTAssertTrue(FlipContainer<EmptyView, EmptyView>.showsBack(91))
        XCTAssertTrue(FlipContainer<EmptyView, EmptyView>.showsBack(180))
        XCTAssertFalse(FlipContainer<EmptyView, EmptyView>.showsBack(360))
        XCTAssertTrue(FlipContainer<EmptyView, EmptyView>.showsBack(-180))
    }

    // MARK: Pocket

    func testHiddenCardsPeekOutWithTheBackCardHighest() {
        let back = KitoWalletPocket.cardOffset(index: 0, count: 3, cardHeight: 100, revealed: false)
        let front = KitoWalletPocket.cardOffset(index: 2, count: 3, cardHeight: 100, revealed: false)
        XCTAssertLessThan(back, front)
        XCTAssertLessThan(front, 0, "even the front card peeks above the pocket")
    }

    func testRevealedCardsRiseAndSpreadFurther() {
        for index in 0..<3 {
            XCTAssertLessThan(KitoWalletPocket.cardOffset(index: index, count: 3, cardHeight: 100, revealed: true),
                              KitoWalletPocket.cardOffset(index: index, count: 3, cardHeight: 100, revealed: false))
        }
        let gap = KitoWalletPocket.cardOffset(index: 1, count: 3, cardHeight: 100, revealed: true) - KitoWalletPocket.cardOffset(index: 0, count: 3, cardHeight: 100, revealed: true)
        XCTAssertEqual(gap, 20, accuracy: 0.001, "each card's top strip shows")
    }

    func testThePocketGrowsTallerWithMoreCards() {
        XCTAssertGreaterThan(KitoWalletPocket.aspectRatio(cardCount: 3), KitoWalletPocket.aspectRatio(cardCount: 6))
    }

    // MARK: Stack & fan

    func testTheStackOverlapsByThePeek() {
        XCTAssertEqual(KitoWalletCardStack<EmptyView>.offset(index: 3, selectedIndex: nil, count: 5, peek: 58, cardHeight: 200, containerHeight: 700), 174)
    }

    func testASelectedCardGoesToTheTopAndTheRestPile() {
        let selected = KitoWalletCardStack<EmptyView>.offset(index: 2, selectedIndex: 2, count: 4, peek: 58, cardHeight: 200, containerHeight: 700)
        XCTAssertEqual(selected, 0)
        let others = [0, 1, 3].map { KitoWalletCardStack<EmptyView>.offset(index: $0, selectedIndex: 2, count: 4, peek: 58, cardHeight: 200, containerHeight: 700) }
        XCTAssertEqual(others, others.sorted(), "the pile keeps the stack's order")
        XCTAssertTrue(others.allSatisfy { $0 > 500 }, "the pile sits at the bottom")
    }

    func testTheFanIsCentred() {
        XCTAssertEqual((0..<5).map { KitoWalletCardFan.angle(index: $0, count: 5, spread: 9) }, [-18, -9, 0, 9, 18])
        XCTAssertEqual(KitoWalletCardFan.angle(index: 0, count: 1, spread: 9), 0)
    }
}
