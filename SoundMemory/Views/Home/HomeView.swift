import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        NavigationStack(path: $env.navigationPath) {
            ZStack {
                LinearGradient(
                    colors: [Color.cream, Color(hex: "#fde8d0")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    VStack(spacing: 16) {
                        SoundWaveVisualiser()

                        Text("Ohrenspiel")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appNavy)

                        Text("Match the sounds")
                            .font(.title3)
                            .foregroundStyle(Color.navyLight)
                    }

                    Spacer()

                    Button {
                        env.navigationPath.append(Route.theme)
                    } label: {
                        Text("Play")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.coral)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            .shadow(color: Color.coral.opacity(0.35), radius: 6, x: 0, y: 4)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .theme:
                    ThemeView()
                case .difficulty(let theme):
                    DifficultyView(theme: theme)
                case .game(let difficulty, let theme):
                    GameView(difficulty: difficulty, theme: theme, audio: env.audio)
                }
            }
        }
    }
}

private struct SoundWaveVisualiser: View {
    private let heights: [CGFloat] = [18, 32, 48, 60, 48, 32, 18]
    private let colors: [Color] = [.sky, .sage, .coral, .gold, .coral, .sage, .sky]

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<7, id: \.self) { i in
                RoundedRectangle(cornerRadius: 99)
                    .fill(colors[i])
                    .frame(width: 6, height: heights[i])
            }
        }
    }
}

#Preview {
    HomeView().environmentObject(AppEnvironment())
}
