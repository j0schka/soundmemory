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

                    VStack(spacing: 12) {
                        Button {
                            env.navigationPath.append(Route.theme(.single))
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "person.fill")
                                Text("Solo")
                            }
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.sage)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            .shadow(color: Color.sage.opacity(0.35), radius: 6, x: 0, y: 4)
                        }

                        Button {
                            env.navigationPath.append(Route.theme(.versus))
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "person.2.fill")
                                Text("2 Players")
                            }
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.coral)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            .shadow(color: Color.coral.opacity(0.35), radius: 6, x: 0, y: 4)
                        }

                        Button {
                            if env.gcManager.isAuthenticated {
                                env.navigationPath.append(Route.theme(.online))
                            } else {
                                // Trigger auth — GK will present its own sign-in UI
                                env.gcManager.authenticate()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "wifi")
                                Text("Online")
                            }
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.sky)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            .shadow(color: Color.sky.opacity(0.35), radius: 6, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .theme(let mode):
                    ThemeView(playerMode: mode)
                case .difficulty(let theme, let mode):
                    if mode == .online {
                        // For online mode, difficulty selection goes to matchmaking
                        DifficultyView(theme: theme, playerMode: mode)
                    } else {
                        DifficultyView(theme: theme, playerMode: mode)
                    }
                case .matchmaking(let difficulty, let theme):
                    MatchmakingView(difficulty: difficulty, theme: theme)
                case .game(let difficulty, let theme, let mode):
                    GameView(
                        difficulty: difficulty,
                        theme: theme,
                        playerMode: mode,
                        audio: env.audio,
                        gcManager: mode == .online ? env.gcManager : nil,
                        initialCards: mode == .online ? env.pendingOnlineDeck : nil
                    )
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
