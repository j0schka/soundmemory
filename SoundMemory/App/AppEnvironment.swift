import SwiftUI

enum Route: Hashable {
    case theme
    case difficulty(SoundTheme)
    case game(Difficulty, SoundTheme)
}

@MainActor
final class AppEnvironment: ObservableObject {
    @Published var navigationPath = NavigationPath()
    let audio = AudioEngine()
}
