import SwiftUI

struct GameView: View {
    let difficulty: Difficulty
    let theme: SoundTheme
    let playerMode: PlayerMode
    @EnvironmentObject private var env: AppEnvironment
    @StateObject private var vm: GameViewModel

    @State private var showDisconnectAlert = false

    init(difficulty: Difficulty, theme: SoundTheme, playerMode: PlayerMode, audio: AudioEngine,
         gcManager: GameCenterManager? = nil, initialCards: [Card]? = nil) {
        self.difficulty = difficulty
        self.theme = theme
        self.playerMode = playerMode
        _vm = StateObject(wrappedValue: GameViewModel(
            difficulty: difficulty,
            theme: theme,
            playerMode: playerMode,
            audio: audio,
            gcManager: gcManager,
            initialCards: initialCards
        ))
    }

    var body: some View {
        VStack(spacing: 12) {
            ScoreBarView(
                players: vm.state.players,
                currentPlayerIndex: vm.state.currentPlayerIndex,
                moves: vm.state.totalMoves,
                timerString: vm.timer.displayString,
                playerMode: playerMode
            )

            if playerMode == .online {
                OnlineTurnBanner(isLocalTurn: vm.isLocalTurn, opponentName: vm.opponentName)
            }

            GeometryReader { geo in
                ScrollView(showsIndicators: false) {
                    VStack {
                        Spacer(minLength: 0)
                        CardGridView(
                            cards: vm.state.cards,
                            columns: difficulty.columns,
                            pulsing: vm.lastMatchedIDs,
                            onCardTap: { vm.cardTapped($0) }
                        )
                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: geo.size.height)
                }
            }
        }
        .padding(.vertical)
        .background(Color.cream.ignoresSafeArea())
        .navigationTitle("\(theme.displayName) · \(difficulty.displayName)")
        .navigationBarTitleDisplayMode(.inline)
        // Observe Game Center events when in online mode
        .onReceive(env.gcManager.$latestEvent.compactMap { $0 }) { event in
            guard playerMode == .online else { return }
            switch event {
            case .cardTapped(let index):
                vm.applyRemoteCardTap(cardIndex: index)
            case .playerDisconnected:
                showDisconnectAlert = true
            case .gameSetup:
                break  // handled in MatchmakingView
            }
        }
        .alert("Opponent disconnected", isPresented: $showDisconnectAlert) {
            Button("Home") {
                env.gcManager.endMatch()
                env.navigationPath = NavigationPath()
            }
        } message: {
            Text("The connection was lost.")
        }
        .fullScreenCover(isPresented: $vm.showPassScreen) {
            PassView(currentPlayer: vm.state.currentPlayer, onReady: { vm.passTapped() })
        }
        .fullScreenCover(isPresented: $vm.showGameOver) {
            GameOverView(
                state: vm.state,
                elapsedSeconds: vm.timer.elapsedSeconds,
                onPlayAgain: { vm.resetGame() },
                onHome: {
                    if playerMode == .online { env.gcManager.endMatch() }
                    env.navigationPath = NavigationPath()
                }
            )
        }
    }
}

// MARK: - Turn indicator

private struct OnlineTurnBanner: View {
    let isLocalTurn: Bool
    let opponentName: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isLocalTurn ? "music.note" : "clock")
                .font(.system(size: 13, weight: .semibold))
            Text(isLocalTurn ? "Your turn" : "\(opponentName) is thinking…")
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundStyle(isLocalTurn ? Color.sage : Color.muted)
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background((isLocalTurn ? Color.sage : Color.muted).opacity(0.12))
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.3), value: isLocalTurn)
    }
}
