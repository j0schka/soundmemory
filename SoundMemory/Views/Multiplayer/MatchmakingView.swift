import SwiftUI
import GameKit

struct MatchmakingView: View {
    let difficulty: Difficulty
    let theme: SoundTheme

    @EnvironmentObject private var env: AppEnvironment
    @State private var showMatchmaker = false
    @State private var matchFound = false      // true after GK match, waiting for setup (guest)
    @State private var showDisconnect = false

    var body: some View {
        ZStack {
            Color.appNavy.ignoresSafeArea()

            // Dot-grid background (same as PassView)
            Canvas { context, size in
                let spacing: CGFloat = 18
                for x in stride(from: 0, to: size.width, by: spacing) {
                    for y in stride(from: 0, to: size.height, by: spacing) {
                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: 3, height: 3)),
                            with: .color(.white.opacity(0.06))
                        )
                    }
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.sky)

                VStack(spacing: 8) {
                    Text(matchFound ? "Waiting for opponent…" : "Looking for an opponent")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("\(theme.displayName) · \(difficulty.displayName)")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.6))
                }

                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.4)

                Spacer()

                Button {
                    env.gcManager.endMatch()
                    env.navigationPath.removeLast()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.15))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { showMatchmaker = true }
        // Present native GK matchmaker sheet
        .sheet(isPresented: $showMatchmaker, onDismiss: {
            // If no match was found (user cancelled), go back
            if !matchFound { env.navigationPath.removeLast() }
        }) {
            MatchmakerSheet(difficulty: difficulty, theme: theme) { match in
                showMatchmaker = false
                handleMatchFound(match)
            } onCancel: {
                showMatchmaker = false
            }
        }
        // Guest: wait for host's gameSetup event, then navigate
        .onReceive(env.gcManager.$latestEvent.compactMap { $0 }) { event in
            if case .gameSetup(let payload) = event, !env.gcManager.isHost {
                guard let receivedTheme = SoundTheme(rawValue: payload.themeName),
                      let receivedDifficulty = Difficulty(rawValue: payload.difficultyName) else { return }
                let cards = rebuildDeck(toneIDs: payload.toneIDs)
                env.pendingOnlineDeck = cards
                env.navigationPath.append(Route.game(receivedDifficulty, receivedTheme, .online))
            }
        }
        .alert("Opponent disconnected", isPresented: $showDisconnect) {
            Button("OK") { env.navigationPath.removeLast() }
        }
    }

    // MARK: - Private

    private func handleMatchFound(_ match: GKMatch) {
        // Host determination: compare player IDs (deterministic on both devices)
        let localID = GKLocalPlayer.local.gamePlayerID
        let opponentID = match.players.first?.gamePlayerID ?? ""
        let isHost = localID < opponentID

        env.gcManager.startMatch(match, isHost: isHost)
        matchFound = true

        if isHost {
            // Host creates the deck and sends it to the guest
            let cards = Card.shuffledDeck(for: difficulty)
            env.pendingOnlineDeck = cards
            let toneIDs = cards.map(\.toneID)
            let payload = GameSetupPayload(
                toneIDs: toneIDs,
                themeName: theme.rawValue,
                difficultyName: difficulty.rawValue
            )
            if let msg = MatchMessage.gameSetup(payload) {
                env.gcManager.send(msg)
            }
            env.navigationPath.append(Route.game(difficulty, theme, .online))
        }
        // Guest stays here until gameSetup event arrives (handled in onReceive above)
    }

    private func rebuildDeck(toneIDs: [Int]) -> [Card] {
        toneIDs.map { Card(id: UUID(), toneID: $0) }
    }
}

// MARK: - GKMatchmakerViewController wrapper

private struct MatchmakerSheet: UIViewControllerRepresentable {
    let difficulty: Difficulty
    let theme: SoundTheme
    let onMatchFound: (GKMatch) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> GKMatchmakerViewController {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        request.inviteMessage = "Let's play Ohrenspiel! Theme: \(theme.displayName), Difficulty: \(difficulty.displayName)"
        let vc = GKMatchmakerViewController(matchRequest: request)!
        vc.matchmakerDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: GKMatchmakerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onMatchFound: onMatchFound, onCancel: onCancel) }

    final class Coordinator: NSObject, GKMatchmakerViewControllerDelegate {
        let onMatchFound: (GKMatch) -> Void
        let onCancel: () -> Void

        init(onMatchFound: @escaping (GKMatch) -> Void, onCancel: @escaping () -> Void) {
            self.onMatchFound = onMatchFound
            self.onCancel = onCancel
        }

        func matchmakerViewController(_ vc: GKMatchmakerViewController, didFind match: GKMatch) {
            DispatchQueue.main.async { self.onMatchFound(match) }
        }

        func matchmakerViewControllerWasCancelled(_ vc: GKMatchmakerViewController) {
            DispatchQueue.main.async { self.onCancel() }
        }

        func matchmakerViewController(_ vc: GKMatchmakerViewController, didFailWithError error: Error) {
            DispatchQueue.main.async { self.onCancel() }
        }
    }
}
