import SwiftUI

struct ScoreBarView: View {
    let players: [Player]
    let currentPlayerIndex: Int
    let moves: Int
    let timerString: String
    let playerMode: PlayerMode

    var body: some View {
        Group {
            if playerMode == .single {
                singlePlayerBar
            } else {
                versusBar
            }
        }
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.appNavy.opacity(0.10), radius: 8, x: 0, y: 4)
        .shadow(color: Color.appNavy.opacity(0.06), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 16)
    }

    private var singlePlayerBar: some View {
        HStack(spacing: 0) {
            VStack(spacing: 2) {
                Text("\(players[0].matchedPairCount)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appNavy)
                Text("pairs")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.muted)
            }
            .frame(maxWidth: .infinity)

            Divider()
                .background(Color.creamDark)
                .frame(height: 44)

            VStack(spacing: 2) {
                Text(timerString)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.appNavy)
                Text("\(moves) moves")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.muted)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var versusBar: some View {
        HStack(spacing: 0) {
            PlayerScoreCell(player: players[0], isActive: currentPlayerIndex == 0)

            Divider()
                .background(Color.creamDark)
                .frame(height: 44)

            VStack(spacing: 2) {
                Text(timerString)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.appNavy)
                Text("\(moves) moves")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.muted)
            }
            .frame(maxWidth: .infinity)

            Divider()
                .background(Color.creamDark)
                .frame(height: 44)

            PlayerScoreCell(player: players[1], isActive: currentPlayerIndex == 1)
        }
    }
}

private struct PlayerScoreCell: View {
    let player: Player
    let isActive: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text(player.displayName)
                .font(.system(size: 13))
                .foregroundStyle(isActive ? Color.appNavy : Color.creamDark)
            Text("\(player.matchedPairCount)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(isActive ? Color.appNavy : Color.creamDark)
            Circle()
                .fill(isActive ? Color.coral : Color.clear)
                .frame(width: 5, height: 5)
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

#Preview {
    VStack(spacing: 20) {
        ScoreBarView(
            players: [Player(id: 1, matchedPairCount: 3)],
            currentPlayerIndex: 0,
            moves: 8,
            timerString: "01:24",
            playerMode: .single
        )
        ScoreBarView(
            players: [Player(id: 1, matchedPairCount: 3), Player(id: 2, matchedPairCount: 1)],
            currentPlayerIndex: 0,
            moves: 8,
            timerString: "01:24",
            playerMode: .versus
        )
    }
    .padding()
    .background(Color.cream)
}
