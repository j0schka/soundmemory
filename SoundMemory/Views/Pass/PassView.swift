import SwiftUI

struct PassView: View {
    let currentPlayer: Player
    let onReady: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            background

            Circle()
                .fill(Color.coral.opacity(0.12))
                .frame(width: 140, height: 140)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.trailing, -30)
                .padding(.top, 60)
                .ignoresSafeArea()

            Circle()
                .fill(Color.gold.opacity(0.15))
                .frame(width: 90, height: 90)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(.leading, -20)
                .padding(.bottom, 120)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.white.opacity(0.9))
                    .scaleEffect(appeared ? 1 : 0.5)
                    .animation(.spring(duration: 0.5, bounce: 0.4), value: appeared)

                VStack(spacing: 8) {
                    Text("Pass the device")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))

                    Text("to \(currentPlayer.displayName)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .opacity(appeared ? 1 : 0)
                .animation(.easeIn(duration: 0.4).delay(0.15), value: appeared)

                Spacer()

                Button(action: onReady) {
                    Text("I'm Ready")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .foregroundStyle(Color.coral)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
                .opacity(appeared ? 1 : 0)
                .animation(.easeIn(duration: 0.3).delay(0.3), value: appeared)
            }
        }
        .onAppear { appeared = true }
        .onDisappear { appeared = false }
    }

    private var background: some View {
        ZStack {
            Color.appNavy.ignoresSafeArea()
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
        }
    }
}

#Preview {
    PassView(currentPlayer: Player(id: 2), onReady: {})
}
