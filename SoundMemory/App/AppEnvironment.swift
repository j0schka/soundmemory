import SwiftUI

enum Route: Hashable {
    case theme(PlayerMode)
    case difficulty(SoundTheme, PlayerMode)
    case matchmaking(Difficulty, SoundTheme)   // online: find opponent before game starts
    case game(Difficulty, SoundTheme, PlayerMode)
}

@MainActor
final class AppEnvironment: ObservableObject {
    @Published var navigationPath = NavigationPath()
    let audio = AudioEngine()
    let gcManager = GameCenterManager()
    let subscriptionManager = SubscriptionManager()
    var pendingOnlineDeck: [Card]? = nil    // set by MatchmakingView before navigating to game
}
