import SwiftUI

struct GameOverView: View {
    let state: GameState
    let elapsedSeconds: Int
    let onPlayAgain: () -> Void
    let onHome: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var cardAppeared = false

    var body: some View {
        ZStack {
            backgroundGradient

            CelebrationView()

            VStack(spacing: 0) {
                Spacer()

                // Result card
                VStack(spacing: 24) {
                    resultHeader

                    Divider()

                    scoreTable

                    Divider()

                    timeRow
                }
                .padding(24)
                .background(.ultraThickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 24)
                .scaleEffect(cardAppeared ? 1 : 0.7)
                .opacity(cardAppeared ? 1 : 0)
                .animation(.spring(duration: 0.6, bounce: 0.3).delay(0.3), value: cardAppeared)

                Spacer()

                actionButtons
                    .opacity(cardAppeared ? 1 : 0)
                    .animation(.easeIn(duration: 0.3).delay(0.7), value: cardAppeared)
            }
        }
        .onAppear {
            cardAppeared = true
            HapticManager.notification(.success)
        }
    }

    private var resultHeader: some View {
        VStack(spacing: 8) {
            Text(winnerEmoji)
                .font(.system(size: 52))
            Text(winnerTitle)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            if let winner = state.winner {
                Text("\(winner.displayName) wins!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var scoreTable: some View {
        HStack(spacing: 0) {
            ForEach(state.players) { player in
                VStack(spacing: 6) {
                    Text(player.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(player.matchedPairCount)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(player.id == state.winner?.id ? .primary : .secondary)
                    Text("pairs")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                if player.id == 1 {
                    Text("vs")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }

    private var timeRow: some View {
        HStack {
            Label("\(state.totalMoves) moves", systemImage: "hand.tap")
            Spacer()
            Label(formattedTime, systemImage: "clock")
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                dismiss()
                onPlayAgain()
            } label: {
                Text("Play Again")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.white)
                    .foregroundStyle(Color(hue: 0.62, saturation: 0.6, brightness: 0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button {
                dismiss()
                onHome()
            } label: {
                Text("Home")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0.15))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 50)
    }

    private var winnerEmoji: String {
        state.winner != nil ? "🏆" : "🤝"
    }

    private var winnerTitle: String {
        state.winner != nil ? "We have a winner!" : "It's a tie!"
    }

    private var formattedTime: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hue: 0.62, saturation: 0.55, brightness: 0.3),
                Color(hue: 0.67, saturation: 0.6, brightness: 0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
