import SwiftUI

struct PulseModifier: ViewModifier {
    let active: Bool
    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: active) { newValue in
                if newValue {
                    withAnimation(
                        .easeInOut(duration: 0.15)
                        .repeatCount(3, autoreverses: true)
                    ) {
                        scale = 1.12
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        scale = 1.0
                    }
                }
            }
    }
}

extension View {
    func pulse(active: Bool) -> some View {
        modifier(PulseModifier(active: active))
    }
}
