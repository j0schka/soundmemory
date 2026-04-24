import SwiftUI

struct DifficultyView: View {
    let theme: SoundTheme
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How many cards?")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.appNavy)
                .padding(.top, 8)

            ForEach(Difficulty.allCases) { difficulty in
                DifficultyButton(difficulty: difficulty) {
                    env.navigationPath.append(Route.game(difficulty, theme))
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .background(Color.cream.ignoresSafeArea())
        .navigationTitle(theme.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct DifficultyButton: View {
    let difficulty: Difficulty
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(badgeColor)
                        .frame(width: 44, height: 44)
                    Text(badgeLetter)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(badgeTextColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.displayName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.appNavy)
                    Text(difficulty.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.navyLight)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.creamDark)
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.appNavy.opacity(0.10), radius: 8, x: 0, y: 4)
            .shadow(color: Color.appNavy.opacity(0.06), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var badgeColor: Color {
        switch difficulty {
        case .easy:   return Color.sage
        case .medium: return Color.gold
        case .hard:   return Color.coral
        }
    }

    private var badgeLetter: String {
        switch difficulty {
        case .easy:   return "E"
        case .medium: return "M"
        case .hard:   return "H"
        }
    }

    private var badgeTextColor: Color {
        switch difficulty {
        case .medium: return Color.appNavy
        default:      return .white
        }
    }
}

#Preview {
    NavigationStack {
        DifficultyView(theme: .city).environmentObject(AppEnvironment())
    }
}
