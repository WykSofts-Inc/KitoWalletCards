# KitoWalletCards

Payment cards and wallets for SwiftUI: card faces, a stitched pocket that reveals your cards and
balance, a wallet-style stack, a carousel, a fan and a swipeable deck. Part of the
[Kito](https://github.com/WykSofts-Inc/KitoDevKit) ecosystem.

Cards only ever hold the last four digits. Brand marks are drawn (a wordmark, a symbol or two
circles), so bring your own brand; don't ship another company's logo without permission.

## Cards

```swift
let card = KitoWalletCard(name: "Everyday", mark: .wordmark("NOVA", italic: true), last4: "4120",
                          holder: "Wycliff N", expiry: "09/29", balance: 7_450, style: .ocean)

KitoWalletCardView(card: card)                                   // front
KitoWalletCardView(card: card, isFlipped: true, cvv: "123")      // flips to the back
KitoWalletCardView(card: card).kitoCardTilt()                    // tilts toward your finger with a sheen
```

Styles: `.ocean`, `.sunset`, `.aqua`, `.midnight`, `.lavender`, `.lime`, `.pearl`, `.gold`, or your
own `KitoWalletCardStyle(colors:foreground:pattern:)` with `.waves`, `.circles`, `.brushed`, `.dots`
or `.gloss`.

## The pocket

Cards tucked into a pocket with the total hidden. Reveal it and they spring out and fan, each
showing its balance, while a glow blooms behind them and the total counts in.

```swift
@State private var isRevealed = false

KitoWalletPocket(cards: cards, isRevealed: $isRevealed, style: .midnight)
```

## Stack, carousel, fan and deck

```swift
KitoWalletCardStack(cards: cards, selection: $selected) { card in TransactionsList(card) }
KitoWalletCardCarousel(cards: cards, selection: $selected)
KitoWalletCardFan(cards: cards, selection: $selected)
KitoWalletCardDeck(cards: cards)
```

Every animation falls back to a plain ease with Reduce Motion.

## Right-to-left

Card faces, the stack, fan and carousel mirror with the layout direction (the card pattern flips with
them). The carousel's neighbours still turn to face the centre, the deck's top card follows your
finger when you swipe it away, and `kitoCardTilt()` tilts towards the finger with the highlight on
the same side, in either direction.

## Installation

```swift
.package(url: "https://github.com/WykSofts-Inc/KitoWalletCards.git", from: "0.1.0")
```

## License

MIT — see [LICENSE](LICENSE).
