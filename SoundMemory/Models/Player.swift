import Foundation

struct Player: Identifiable, Equatable {
    let id: Int
    var matchedPairCount: Int = 0
    var gcDisplayName: String?                          // set for Game Center players
    var displayName: String { gcDisplayName ?? "Player \(id)" }
}
