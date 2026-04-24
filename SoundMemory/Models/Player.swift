import Foundation

struct Player: Identifiable, Equatable {
    let id: Int
    var matchedPairCount: Int = 0
    var displayName: String { "Player \(id)" }
}
