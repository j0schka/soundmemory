import SwiftUI

struct ThemeView: View {
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(SoundTheme.allCases) { theme in
                    ThemeCard(theme: theme) {
                        env.navigationPath.append(Route.difficulty(theme))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Choose Theme")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ThemeCard: View {
    let theme: SoundTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(iconBackground)
                        .frame(width: 64, height: 64)
                    Image(systemName: theme.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(theme.displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(theme.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    soundPills
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }

    private var soundPills: some View {
        let names = theme.allDescriptors.prefix(4).map(\.name)
        return HStack(spacing: 6) {
            ForEach(names, id: \.self) { name in
                Text(name)
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(iconBackground.opacity(0.15))
                    .foregroundStyle(iconBackground)
                    .clipShape(Capsule())
            }
            Text("…")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.tertiary)
        }
    }

    private var iconBackground: Color {
        switch theme {
        case .musical: return Color(hue: 0.67, saturation: 0.6, brightness: 0.7)
        case .city:    return Color(hue: 0.08, saturation: 0.75, brightness: 0.75)
        case .animals: return Color(hue: 0.35, saturation: 0.6, brightness: 0.55)
        }
    }
}

#Preview {
    NavigationStack {
        ThemeView().environmentObject(AppEnvironment())
    }
}
