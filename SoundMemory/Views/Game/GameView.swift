import SwiftUI

struct GameView: View {
    let difficulty: Difficulty
    let theme: SoundTheme
    @EnvironmentObject private var env: AppEnvironment
    @StateObject private var vm: GameViewModel

    init(difficulty: Difficulty, theme: SoundTheme, audio: AudioEngine) {
        self.difficulty = difficulty
        self.theme = theme
        _vm = StateObject(wrappedValue: GameViewModel(difficulty: difficulty, theme: theme, audio: audio))
    }

    var body: some View {
        VStack(spacing: 12) {
            ScoreBarView(
                players: vm.state.players,
                currentPlayerIndex: vm.state.currentPlayerIndex,
                moves: vm.state.totalMoves,
                timerString: vm.timer.displayString
            )

            Spacer(minLength: 0)

            CardGridView(
                cards: vm.state.cards,
                columns: difficulty.columns,
                pulsing: vm.lastMatchedIDs,
                onCardTap: { vm.cardTapped($0) }
            )

            Spacer(minLength: 0)
        }
        .padding(.vertical)
        .background(Color.cream.ignoresSafeArea())
        .navigationTitle("\(theme.displayName) · \(difficulty.displayName)")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $vm.showPassScreen) {
            PassView(
                currentPlayer: vm.state.currentPlayer,
                onReady: { vm.passTapped() }
            )
        }
        .fullScreenCover(isPresented: $vm.showGameOver) {
            GameOverView(
                state: vm.state,
                elapsedSeconds: vm.timer.elapsedSeconds,
                onPlayAgain: { vm.resetGame() },
                onHome: { env.navigationPath = NavigationPath() }
            )
        }
    }
}
