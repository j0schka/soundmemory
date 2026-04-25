import SwiftUI

struct ThemeView: View {
    let playerMode: PlayerMode
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("What do you want to hear?")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.appNavy)
                    .padding(.top, 8)

                ForEach(SoundTheme.allCases) { theme in
                    ThemeCard(theme: theme) {
                        env.navigationPath.append(Route.difficulty(theme, playerMode))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.cream.ignoresSafeArea())
        .navigationTitle("Choose Theme")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ThemeCard: View {
    let theme: SoundTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(iconBoxBackground)
                        .frame(width: 56, height: 56)
                    Image(systemName: theme.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(iconColor)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(theme.displayName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.appNavy)

                    Text(theme.description)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.navyLight)
                        .fixedSize(horizontal: false, vertical: true)

                    soundPills
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.creamDark)
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.appNavy.opacity(0.10), radius: 8, x: 0, y: 4)
            .shadow(color: Color.appNavy.opacity(0.06), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var soundPills: some View {
        let names = theme.allDescriptors.prefix(4).map(\.name)
        return HStack(spacing: 6) {
            ForEach(names, id: \.self) { name in
                Text(name)
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(iconColor.opacity(0.12))
                    .foregroundStyle(iconColor)
                    .clipShape(Capsule())
            }
            Text("…")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.muted)
        }
    }

    private var iconBoxBackground: Color {
        switch theme {
        case .musical:   return Color.skyLight
        case .city:      return Color.tanLight
        case .animals:   return Color.sageLight
        case .household: return Color.goldLight
        }
    }

    private var iconColor: Color {
        switch theme {
        case .musical:   return Color.sky
        case .city:      return Color.tangerine
        case .animals:   return Color.sage
        case .household: return Color.gold
        }
    }
}

#Preview {
    NavigationStack {
        ThemeView(playerMode: .versus).environmentObject(AppEnvironment())
    }
}
