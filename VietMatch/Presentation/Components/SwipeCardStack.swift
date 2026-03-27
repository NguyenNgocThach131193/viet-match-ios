import SwiftUI

struct SwipeCardStack<Content: View>: View {
    let cards: [AnyView]
    let onSwipeLeft: (Int) -> Void
    let onSwipeRight: (Int) -> Void

    @State private var currentIndex = 0

    init<Data: RandomAccessCollection>(
        _ data: Data,
        onSwipeLeft: @escaping (Int) -> Void,
        onSwipeRight: @escaping (Int) -> Void,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) where Data.Index == Int {
        self.cards = data.map { AnyView(content($0)) }
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
    }

    var body: some View {
        ZStack {
            ForEach(Array(cards.enumerated().reversed()), id: \.offset) { index, card in
                if index >= currentIndex && index < currentIndex + 3 {
                    card
                        .scaleEffect(index == currentIndex ? 1 : 1 - CGFloat(index - currentIndex) * 0.05)
                        .offset(y: CGFloat(index - currentIndex) * 8)
                        .allowsHitTesting(index == currentIndex)
                }
            }
        }
    }
}
