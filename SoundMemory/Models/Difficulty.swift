import Foundation

enum Difficulty: String, CaseIterable, Identifiable, Hashable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var columns: Int { 4 }

    var rows: Int {
        switch self {
        case .easy:   return 2
        case .medium: return 4
        case .hard:   return 6
        }
    }

    var pairCount: Int { (columns * rows) / 2 }
    var cardCount: Int { columns * rows }
    var displayName: String { rawValue.capitalized }

    var subtitle: String {
        "\(columns)×\(rows) grid · \(pairCount) pairs"
    }
}
