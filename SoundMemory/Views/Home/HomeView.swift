import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        NavigationStack(path: $env.navigationPath) {
            ZStack {
                backgroundGradient

                VStack(spacing: 40) {
                    Spacer()

                    VStack(spacing: 12) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 64))
                            .foregroundStyle(.white)
                            .shadow(radius: 8)

                        Text("SoundMemory")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Match the sounds")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.75))
                    }

                    Spacer()

                    Button {
                        env.navigationPath.append(Route.theme)
                    } label: {
                        Text("Play")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.white)
                            .foregroundStyle(Color(hue: 0.62, saturation: 0.6, brightness: 0.35))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
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

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hue: 0.62, saturation: 0.55, brightness: 0.45),
                Color(hue: 0.67, saturation: 0.6, brightness: 0.35)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    HomeView().environmentObject(AppEnvironment())
}
