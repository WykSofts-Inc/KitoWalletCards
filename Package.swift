// swift-tools-version: 5.9
//
//  Package.swift
//  KitoWalletCards
//
//  Created by Wycliff on 9/23/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "KitoWalletCards",
    platforms: [.iOS(.v17)],
    products: [.library(name: "KitoWalletCards", targets: ["KitoWalletCards"])],
    targets: [
        .target(name: "KitoWalletCards"),
        .testTarget(name: "KitoWalletCardsTests", dependencies: ["KitoWalletCards"]),
    ]
)
