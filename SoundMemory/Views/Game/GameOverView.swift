import SwiftUI

struct GameOverView: View {
    let state: GameState
    let elapsedSeconds: Int
    let onPlayAgain: () -> Void
    let onHome: () -> Void

    @EnvironmentObject private var env: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    @State private var cardAppeared = false
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.coral, Color.gold],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            CelebrationView()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    if state.playerMode == .single {
                        singlePlayerResult
                    } else {
                        versusResult
                    }
                }
                .padding(24)
                .background(Color.white.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .shadow(color: Color.appNavy.opacity(0.14), radius: 16, x: 0, y: 8)
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
            // Count the round that just finished (not when the next one starts)
            env.subscriptionManager.recordRoundStarted()
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView {
                showPaywall = false
                dismiss()
                onPlayAgain()
            } onDismiss: {
                showPaywall = false
                dismiss()
                onHome()
            }
        }
    }

    // MARK: - Single player result

    private var singlePlayerResult: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("🎉")
                    .font(.system(size: 52))
                Text("Well done!")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appNavy)
            }

            Divider().background(Color.creamDark)

            HStack(spacing: 0) {
                statCell(value: "\(state.totalMoves)", label: "moves")
                Divider().frame(height: 44).background(Color.creamDark)
                statCell(value: formattedTime, label: "time")
            }
        }
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appNavy)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(Color.navyLight)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Versus result

    private var versusResult: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(winnerEmoji)
                    .font(.system(size: 52))
                Text(winnerTitle)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appNavy)
                if let winner = state.winner {
                    Text("\(winner.displayName) wins!")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.navyLight)
                }
            }

            Divider().background(Color.creamDark)

            HStack(spacing: 0) {
                ForEach(state.players) { player in
                    let isWinner = player.id == state.winner?.id
                    VStack(spacing: 6) {
                        Text(player.displayName)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.navyLight)
                        Text("\(player.matchedPairCount)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(isWinner ? Color.appNavy : Color.creamDark)
                        Text("pairs")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.navyLight)
                    }
                    .frame(maxWidth: .infinity)

                    if player.id == 1 {
                        Text("vs")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.creamDark)
                    }
                }
            }

            Divider().background(Color.creamDark)

            HStack {
                Label("\(state.totalMoves) moves", systemImage: "hand.tap")
                Spacer()
                Label(formattedTime, systemImage: "clock")
            }
            .font(.system(size: 15))
            .foregroundStyle(Color.navyLight)
        }
    }

    // MARK: - Shared

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                if env.subscriptionManager.canPlay {
                    dismiss()
                    onPlayAgain()
                } else {
                    showPaywall = true
                }
            } label: {
                Text("Play Again")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .foregroundStyle(Color.coral)
                    .clipShape(Capsule())
            }

            Button {
                dismiss()
                onHome()
            } label: {
                Text("Home")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.20))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 60)
    }

    private var winnerEmoji: String { state.winner != nil ? "🏆" : "🤝" }
    private var winnerTitle: String { state.winner != nil ? "We have a winner!" : "It's a tie!" }

    private var formattedTime: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
