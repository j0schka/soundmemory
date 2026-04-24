import SwiftUI

struct PassView: View {
    let currentPlayer: Player
    let onReady: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            Color(hue: 0.62, saturation: 0.6, brightness: 0.15)
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
                        .font(.title3)
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
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white)
                        .foregroundStyle(Color(hue: 0.62, saturation: 0.6, brightness: 0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
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
}

#Preview {
    PassView(currentPlayer: Player(id: 2), onReady: {})
}
