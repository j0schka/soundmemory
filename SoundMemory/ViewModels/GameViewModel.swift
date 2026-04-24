import SwiftUI

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var state: GameState
    @Published var showPassScreen: Bool = false
    @Published var showGameOver: Bool = false
    @Published private(set) var lastMatchedIDs: Set<UUID> = []
    @Published private(set) var timer = TimerViewModel()

    private let audio: AudioEngine
    private var matchCheckTask: Task<Void, Never>?
    private var timerStarted = false

    init(difficulty: Difficulty, theme: SoundTheme, audio: AudioEngine) {
        self.audio = audio
        self.state = GameState(
            cards: Card.shuffledDeck(for: difficulty),
            players: [Player(id: 1), Player(id: 2)],
            difficulty: difficulty,
            theme: theme
        )
        audio.preloadTones(theme.tones(for: difficulty))
    }

    // MARK: - Public Actions

    func cardTapped(_ card: Card) {
        guard !card.isMatched, !card.isFaceUp else { return }

        switch state.phase {
        case .idle:
            if !timerStarted {
                timer.start()
                timerStarted = true
            }
            state.setFaceUp(true, cardID: card.id)
            audio.play(toneID: card.toneID)
            state.phase = .firstCardRevealed(cardID: card.id)

        case .firstCardRevealed(let firstID):
            guard card.id != firstID else { return }
            state.setFaceUp(true, cardID: card.id)
            audio.play(toneID: card.toneID)
            state.totalMoves += 1
            state.phase = .secondCardRevealed(firstID: firstID, secondID: card.id)
            scheduleMatchCheck(firstID: firstID, secondID: card.id)

        default:
            break
        }
    }

    func passTapped() {
        showPassScreen = false
        timer.resume()
        state.phase = .idle
    }

    func resetGame() {
        matchCheckTask?.cancel()
        timer.reset()
        timerStarted = false
        showPassScreen = false
        showGameOver = false
        lastMatchedIDs = []
        let difficulty = state.difficulty
        let theme = state.theme
        state = GameState(
            cards: Card.shuffledDeck(for: difficulty),
            players: [Player(id: 1), Player(id: 2)],
            difficulty: difficulty,
            theme: theme
        )
        audio.preloadTones(theme.tones(for: difficulty))
    }

    // MARK: - Private

    private func scheduleMatchCheck(firstID: UUID, secondID: UUID) {
        matchCheckTask?.cancel()
        matchCheckTask = Task {
            try? await Task.sleep(for: .milliseconds(800))
            guard !Task.isCancelled else { return }
            await evaluateMatch(firstID: firstID, secondID: secondID)
        }
    }

    private func evaluateMatch(firstID: UUID, secondID: UUID) async {
        state.phase = .checkingMatch
        guard let first = state.card(withID: firstID),
              let second = state.card(withID: secondID) else { return }

        if first.toneID == second.toneID {
            state.setMatched(cardID: firstID)
            state.setMatched(cardID: secondID)
            state.players[state.currentPlayerIndex].matchedPairCount += 1
            HapticManager.impact(.medium)

            lastMatchedIDs = [firstID, secondID]
            try? await Task.sleep(for: .milliseconds(500))
            lastMatchedIDs = []

            if state.isGameOver {
                timer.stop()
                state.phase = .gameOver
                HapticManager.notification(.success)
                showGameOver = true
            } else {
                state.phase = .idle
            }
        } else {
            state.setFaceUp(false, cardID: firstID)
            state.setFaceUp(false, cardID: secondID)
            state.currentPlayerIndex = state.currentPlayerIndex == 0 ? 1 : 0
            state.phase = .passScreen
            timer.pause()
            showPassScreen = true
        }
    }
}
