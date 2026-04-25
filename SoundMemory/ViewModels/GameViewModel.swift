import SwiftUI

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var state: GameState
    @Published var showPassScreen: Bool = false
    @Published var showGameOver: Bool = false
    @Published private(set) var lastMatchedIDs: Set<UUID> = []
    @Published private(set) var timer = TimerViewModel()

    private let audio: AudioEngine
    private let gcManager: GameCenterManager?
    private var matchCheckTask: Task<Void, Never>?
    private var timerStarted = false

    // True when it is the local player's turn (always true for non-online modes)
    var isLocalTurn: Bool {
        guard state.playerMode == .online else { return true }
        return state.isLocalPlayerHost
            ? state.currentPlayerIndex == 0
            : state.currentPlayerIndex == 1
    }

    var opponentName: String {
        state.players.first(where: { $0.id != localPlayerID })?.displayName ?? "Opponent"
    }

    private var localPlayerID: Int {
        state.playerMode == .online && !state.isLocalPlayerHost ? 2 : 1
    }

    // MARK: - Init

    init(difficulty: Difficulty,
         theme: SoundTheme,
         playerMode: PlayerMode,
         audio: AudioEngine,
         gcManager: GameCenterManager? = nil,
         initialCards: [Card]? = nil) {
        self.audio = audio
        self.gcManager = gcManager

        let isHost = gcManager?.isHost ?? true

        let players: [Player]
        if playerMode == .online, let gcm = gcManager {
            let localName = gcm.localPlayerName
            let opponentName = gcm.opponentDisplayName
            players = [
                Player(id: 1, gcDisplayName: isHost ? localName : opponentName),
                Player(id: 2, gcDisplayName: isHost ? opponentName : localName)
            ]
        } else if playerMode == .single {
            players = [Player(id: 1)]
        } else {
            players = [Player(id: 1), Player(id: 2)]
        }

        let cards = initialCards ?? Card.shuffledDeck(for: difficulty)
        self.state = GameState(
            cards: cards,
            players: players,
            difficulty: difficulty,
            theme: theme,
            playerMode: playerMode,
            isLocalPlayerHost: isHost
        )
        audio.preloadTones(theme.tones(for: difficulty))
    }

    // MARK: - Public Actions

    func cardTapped(_ card: Card) {
        // Online: block taps when it's not the local player's turn
        guard isLocalTurn else { return }
        internalCardTapped(card, sendRemote: state.playerMode == .online)
    }

    // Called by GameView when a remote card-tap event arrives
    func applyRemoteCardTap(cardIndex: Int) {
        guard cardIndex < state.cards.count else { return }
        internalCardTapped(state.cards[cardIndex], sendRemote: false)
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
        let playerMode = state.playerMode
        let players: [Player] = playerMode == .single
            ? [Player(id: 1)]
            : [Player(id: 1), Player(id: 2)]
        state = GameState(
            cards: Card.shuffledDeck(for: difficulty),
            players: players,
            difficulty: difficulty,
            theme: theme,
            playerMode: playerMode
        )
        audio.preloadTones(theme.tones(for: difficulty))
    }

    // MARK: - Private

    private func internalCardTapped(_ card: Card, sendRemote: Bool) {
        guard !card.isMatched, !card.isFaceUp else { return }

        switch state.phase {
        case .idle:
            if !timerStarted { timer.start(); timerStarted = true }
            state.setFaceUp(true, cardID: card.id)
            audio.play(toneID: card.toneID)
            state.phase = .firstCardRevealed(cardID: card.id)
            if sendRemote { sendCardTapped(card) }

        case .firstCardRevealed(let firstID):
            guard card.id != firstID else { return }
            state.setFaceUp(true, cardID: card.id)
            audio.play(toneID: card.toneID)
            state.totalMoves += 1
            state.phase = .secondCardRevealed(firstID: firstID, secondID: card.id)
            if sendRemote { sendCardTapped(card) }
            scheduleMatchCheck(firstID: firstID, secondID: card.id)

        default:
            break
        }
    }

    private func sendCardTapped(_ card: Card) {
        guard let index = state.cards.firstIndex(where: { $0.id == card.id }),
              let msg = MatchMessage.cardTapped(index: index) else { return }
        gcManager?.send(msg)
    }

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
            // Match
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
                state.phase = .idle  // same player keeps the turn
            }
        } else {
            // No match — show cards briefly then flip back
            try? await Task.sleep(for: .milliseconds(1200))
            state.setFaceUp(false, cardID: firstID)
            state.setFaceUp(false, cardID: secondID)

            switch state.playerMode {
            case .versus:
                state.currentPlayerIndex = state.currentPlayerIndex == 0 ? 1 : 0
                state.phase = .passScreen
                timer.pause()
                showPassScreen = true
            case .online:
                state.currentPlayerIndex = state.currentPlayerIndex == 0 ? 1 : 0
                state.phase = .idle
            case .single:
                state.phase = .idle
            }
        }
    }
}
