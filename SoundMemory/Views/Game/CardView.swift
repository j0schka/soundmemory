import SwiftUI

struct CardView: View {
    let card: Card
    let isPulsing: Bool
    let onTap: () -> Void

    var body: some View {
        ZStack {
            CardBackFace()
                .opacity(card.isFaceUp ? 0 : 1)
                .rotation3DEffect(
                    .degrees(card.isFaceUp ? -90 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )

            CardFrontFace(toneID: card.toneID, isMatched: card.isMatched)
                .opacity(card.isFaceUp ? 1 : 0)
                .rotation3DEffect(
                    .degrees(card.isFaceUp ? 0 : 90),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .animation(.easeInOut(duration: Constants.cardFlipDuration), value: card.isFaceUp)
        .pulse(active: isPulsing)
        .onTapGesture {
            HapticManager.impact(.light)
            onTap()
        }
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(.isButton)
    }

    private var accessibilityDescription: String {
        if card.isMatched { return "Card, matched" }
        if card.isFaceUp { return "Card, tone \(card.toneID + 1), face up" }
        return "Card, face down"
    }
}

private struct CardFrontFace: View {
    let toneID: Int
    let isMatched: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
            .fill(Color(hue: 0.62, saturation: 0.5, brightness: 0.55).opacity(isMatched ? 0.45 : 1.0))
            .overlay {
                VStack(spacing: 6) {
                    Image(systemName: isMatched ? "checkmark.circle.fill" : "music.note")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("\(toneID + 1)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
    }
}

private struct CardBackFace: View {
    var body: some View {
        RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
            .fill(
                LinearGradient(
                    colors: [Color(hue: 0.62, saturation: 0.5, brightness: 0.35),
                             Color(hue: 0.62, saturation: 0.6, brightness: 0.25)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: "questionmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
            }
    }
}

#Preview {
    HStack {
        CardView(card: Card(id: UUID(), toneID: 0), isPulsing: false, onTap: {})
        CardView(card: Card(id: UUID(), toneID: 2, isFaceUp: true), isPulsing: false, onTap: {})
        CardView(card: Card(id: UUID(), toneID: 4, isFaceUp: true, isMatched: true), isPulsing: true, onTap: {})
    }
    .padding()
    .frame(height: 120)
}
