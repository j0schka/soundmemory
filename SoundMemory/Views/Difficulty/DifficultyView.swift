import SwiftUI

struct DifficultyView: View {
    let theme: SoundTheme
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Difficulty")
                .font(.title2.bold())
                .padding(.top, 8)

            ForEach(Difficulty.allCases) { difficulty in
                DifficultyButton(difficulty: difficulty) {
                    env.navigationPath.append(Route.game(difficulty, theme))
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle(theme.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct DifficultyButton: View {
    let difficulty: Difficulty
    let action: () -> Void

    private var icon: String {
        switch difficulty {
        case .easy:   return "circle.grid.2x2"
        case .medium: return "circle.grid.3x3"
        case .hard:   return "square.grid.4x3.fill"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .frame(width: 44)
                    .foregroundStyle(accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.displayName)
                        .font(.headline)
                    Text(difficulty.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private var accentColor: Color {
        switch difficulty {
        case .easy:   return .green
        case .medium: return .orange
        case .hard:   return .red
        }
    }
}

#Preview {
    NavigationStack {
        DifficultyView(theme: .city).environmentObject(AppEnvironment())
    }
}
