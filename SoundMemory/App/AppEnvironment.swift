import SwiftUI

enum Route: Hashable {
    case theme(PlayerMode)
    case difficulty(SoundTheme, PlayerMode)
    case game(Difficulty, SoundTheme, PlayerMode)
}

@MainActor
final class AppEnvironment: ObservableObject {
    @Published var navigationPath = NavigationPath()
    let audio = AudioEngine()
}
