import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }

    static let cream       = Color(hex: "#fef7ec")
    static let creamDark   = Color(hex: "#f5ead6")
    static let appNavy     = Color(hex: "#3d405b")
    static let navyLight   = Color(hex: "#545878")
    static let muted       = Color(hex: "#8a8faa")
    static let coral       = Color(hex: "#e07a5f")
    static let coralLight  = Color(hex: "#f5b8a8")
    static let gold        = Color(hex: "#f4c74a")
    static let goldLight   = Color(hex: "#fce99d")
    static let sage        = Color(hex: "#6dab8b")
    static let sageLight   = Color(hex: "#b5dcc9")
    static let sky         = Color(hex: "#5ba4cf")
    static let skyLight    = Color(hex: "#aed4ee")
    static let tangerine   = Color(hex: "#f4834f")
    static let tanLight    = Color(hex: "#fbbfa0")
    static let plum        = Color(hex: "#9e7bb5")
}
