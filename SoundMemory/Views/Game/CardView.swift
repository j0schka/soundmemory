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

            CardFrontFace(isMatched: card.isMatched)
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
    let isMatched: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
            .fill(isMatched ? Color.sage : Color.sky)
            .overlay {
                Image(systemName: isMatched ? "checkmark.circle.fill" : "music.note")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .shadow(color: Color.appNavy.opacity(0.10), radius: 8, x: 0, y: 4)
            .shadow(color: Color.appNavy.opacity(0.06), radius: 2, x: 0, y: 1)
    }
}

private struct CardBackFace: View {
    var body: some View {
        RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
            .fill(Color.appNavy)
            .overlay {
                Canvas { context, size in
                    let cx = size.width / 2
                    let pairs = 6
                    for i in 0..<pairs {
                        let spread = CGFloat(i + 1) * 18
                        var pathL = Path()
                        pathL.move(to: CGPoint(x: cx, y: size.height))
                        pathL.addCurve(
                            to: CGPoint(x: cx - spread * 2.2, y: 0),
                            control1: CGPoint(x: cx - spread, y: size.height * 0.75),
                            control2: CGPoint(x: cx - spread * 1.5, y: size.height * 0.3)
                        )
                        context.stroke(pathL, with: .color(.white.opacity(0.10)), lineWidth: 1.5)

                        var pathR = Path()
                        pathR.move(to: CGPoint(x: cx, y: size.height))
                        pathR.addCurve(
                            to: CGPoint(x: cx + spread * 2.2, y: 0),
                            control1: CGPoint(x: cx + spread, y: size.height * 0.75),
                            control2: CGPoint(x: cx + spread * 1.5, y: size.height * 0.3)
                        )
                        context.stroke(pathR, with: .color(.white.opacity(0.10)), lineWidth: 1.5)
                    }
                    context.fill(
                        Path(ellipseIn: CGRect(x: cx - 4, y: size.height - 4, width: 8, height: 8)),
                        with: .color(.white.opacity(0.12))
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
            }
            .shadow(color: Color.appNavy.opacity(0.10), radius: 8, x: 0, y: 4)
            .shadow(color: Color.appNavy.opacity(0.06), radius: 2, x: 0, y: 1)
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
    .background(Color.cream)
}
