import Foundation

struct Card: Identifiable, Equatable {
    let id: UUID
    let toneID: Int
    var isFaceUp: Bool = false
    var isMatched: Bool = false

    static func shuffledDeck(for difficulty: Difficulty) -> [Card] {
        (0..<difficulty.pairCount).flatMap { toneID in
            [Card(id: UUID(), toneID: toneID),
             Card(id: UUID(), toneID: toneID)]
        }.shuffled()
    }
}
