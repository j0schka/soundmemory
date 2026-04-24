import SwiftUI

enum Constants {
    static let cardCornerRadius: CGFloat = 12
    static let cardAspectRatio: CGFloat = 0.75
    static let gridSpacing: CGFloat = 8
    static let cardFlipDuration: TimeInterval = 0.35

    // One accent color per tone ID (12 total)
    static let toneColors: [Color] = [
        Color(hue: 0.00, saturation: 0.8, brightness: 0.9), // red
        Color(hue: 0.08, saturation: 0.8, brightness: 0.9), // orange
        Color(hue: 0.14, saturation: 0.8, brightness: 0.9), // yellow
        Color(hue: 0.33, saturation: 0.7, brightness: 0.8), // green
        Color(hue: 0.50, saturation: 0.7, brightness: 0.85), // cyan
        Color(hue: 0.58, saturation: 0.75, brightness: 0.9), // blue
        Color(hue: 0.67, saturation: 0.7, brightness: 0.85), // indigo
        Color(hue: 0.75, saturation: 0.7, brightness: 0.85), // purple
        Color(hue: 0.83, saturation: 0.7, brightness: 0.9), // pink
        Color(hue: 0.92, saturation: 0.6, brightness: 0.9), // rose
        Color(hue: 0.45, saturation: 0.6, brightness: 0.75), // teal
        Color(hue: 0.10, saturation: 0.5, brightness: 0.8), // amber
    ]

    static func color(for toneID: Int) -> Color {
        toneColors[toneID % toneColors.count]
    }
}
