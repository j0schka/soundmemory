import SwiftUI

struct ScoreBarView: View {
    let players: [Player]
    let currentPlayerIndex: Int
    let moves: Int
    let timerString: String

    var body: some View {
        HStack(spacing: 0) {
            PlayerScoreCell(
                player: players[0],
                isActive: currentPlayerIndex == 0
            )

            Divider()
                .frame(height: 44)

            VStack(spacing: 2) {
                Text(timerString)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)
                Text("\(moves) moves")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider()
                .frame(height: 44)

            PlayerScoreCell(
                player: players[1],
                isActive: currentPlayerIndex == 1
            )
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }
}

private struct PlayerScoreCell: View {
    let player: Player
    let isActive: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text(player.displayName)
                .font(.caption)
                .foregroundStyle(isActive ? .primary : .secondary)
            Text("\(player.matchedPairCount)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(isActive ? .primary : .secondary)
            if isActive {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 5, height: 5)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 5, height: 5)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

#Preview {
    ScoreBarView(
        players: [Player(id: 1, matchedPairCount: 3), Player(id: 2, matchedPairCount: 1)],
        currentPlayerIndex: 0,
        moves: 8,
        timerString: "01:24"
    )
    .padding()
}
