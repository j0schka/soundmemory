import Foundation

enum GamePhase: Equatable {
    case idle
    case firstCardRevealed(cardID: UUID)
    case secondCardRevealed(firstID: UUID, secondID: UUID)
    case checkingMatch
    case passScreen
    case gameOver
}

struct GameState {
    var cards: [Card]
    var players: [Player]
    var currentPlayerIndex: Int = 0
    var phase: GamePhase = .idle
    var totalMoves: Int = 0
    var difficulty: Difficulty
    var theme: SoundTheme
    var playerMode: PlayerMode
    var isLocalPlayerHost: Bool = true   // online mode only: host = currentPlayerIndex 0

    var currentPlayer: Player { players[currentPlayerIndex] }

    var isGameOver: Bool { cards.allSatisfy(\.isMatched) }

    var winner: Player? {
        guard playerMode == .versus else { return nil }
        guard players[0].matchedPairCount != players[1].matchedPairCount else { return nil }
        return players.max(by: { $0.matchedPairCount < $1.matchedPairCount })
    }

    func card(withID id: UUID) -> Card? {
        cards.first(where: { $0.id == id })
    }

    mutating func setFaceUp(_ faceUp: Bool, cardID: UUID) {
        guard let idx = cards.firstIndex(where: { $0.id == cardID }) else { return }
        cards[idx].isFaceUp = faceUp
    }

    mutating func setMatched(cardID: UUID) {
        guard let idx = cards.firstIndex(where: { $0.id == cardID }) else { return }
        cards[idx].isMatched = true
        cards[idx].isFaceUp = true
    }
}
