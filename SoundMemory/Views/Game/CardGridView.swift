import SwiftUI

struct CardGridView: View {
    let cards: [Card]
    let columns: Int
    let pulsing: Set<UUID>
    let onCardTap: (Card) -> Void

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Constants.gridSpacing), count: columns)
    }

    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: Constants.gridSpacing) {
            ForEach(cards) { card in
                CardView(
                    card: card,
                    isPulsing: pulsing.contains(card.id),
                    onTap: { onCardTap(card) }
                )
                .aspectRatio(Constants.cardAspectRatio, contentMode: .fit)
            }
        }
        .padding(.horizontal, Constants.gridSpacing)
    }
}
