# ``KitoWalletCards``

Payment cards and wallets for SwiftUI, from single card faces to a pocket, stack, carousel, fan and deck.

## Overview

A ``KitoWalletCard`` describes one card: its name, brand mark, last four
digits, holder, expiry, balance and ``KitoWalletCardStyle``.
``KitoWalletCardView`` draws its front, or flips to the back to show a CVV, and
the `kitoCardTilt()` modifier tilts it toward the user's finger with a moving
sheen.

```swift
let card = KitoWalletCard(name: "Everyday", mark: .wordmark("NOVA", italic: true), last4: "4120",
                          holder: "Wycliff N", expiry: "09/29", balance: 7_450, style: .ocean)

KitoWalletCardView(card: card)
KitoWalletCardView(card: card, isFlipped: true, cvv: "123")
KitoWalletCardView(card: card).kitoCardTilt()
```

Pick one of the built-in styles, such as `.ocean`, `.midnight` or `.gold`, or
build your own from colours and a ``KitoWalletCardPattern``. Cards only ever
hold the last four digits, and brand marks are drawn as a wordmark, a symbol or
two circles, so you bring your own brand.

To show several cards, ``KitoWalletPocket`` tucks them into a stitched pocket
that reveals each balance and the total, ``KitoWalletCardStack`` gives a
wallet-style stack with a detail view, and ``KitoWalletCardCarousel``,
``KitoWalletCardFan`` and ``KitoWalletCardDeck`` offer other arrangements. Every
animation falls back to a plain ease with Reduce Motion.

## Topics

### Cards

- ``KitoWalletCard``
- ``KitoWalletCardView``
- ``KitoWalletCardMark``
- ``KitoWalletCardMarkView``

### Appearance

- ``KitoWalletCardStyle``
- ``KitoWalletCardPattern``
- ``KitoWalletCardGeometry``

### Wallet Layouts

- ``KitoWalletPocket``
- ``KitoWalletPocketStyle``
- ``KitoPocketShape``
- ``KitoWalletCardStack``
- ``KitoWalletCardCarousel``
- ``KitoWalletCardFan``
- ``KitoWalletCardDeck``
