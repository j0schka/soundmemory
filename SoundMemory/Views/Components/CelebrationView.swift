import SwiftUI

struct CelebrationView: View {
    @State private var animate = false

    private let particles: [Particle] = (0..<60).map { _ in Particle() }

    var body: some View {
        GeometryReader { geo in
            ForEach(particles.indices, id: \.self) { i in
                let p = particles[i]
                Group {
                    if p.isCircle {
                        Circle()
                            .fill(p.color)
                            .frame(width: p.size, height: p.size)
                    } else {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(p.color)
                            .frame(width: p.size * 0.7, height: p.size * 1.4)
                            .rotationEffect(.degrees(animate ? p.finalRotation : p.startRotation))
                    }
                }
                .position(
                    x: p.xPosition * geo.size.width,
                    y: animate ? (geo.size.height + 40) : -20
                )
                .animation(
                    .spring(duration: Double.random(in: 1.0...1.8), bounce: 0.2)
                    .delay(Double(i) * 0.018),
                    value: animate
                )
                .opacity(animate ? 0.85 : 0)
                .animation(.easeIn(duration: 0.2).delay(Double(i) * 0.018), value: animate)
            }
        }
        .onAppear { animate = true }
        .allowsHitTesting(false)
    }
}

private struct Particle {
    let color: Color
    let size: CGFloat
    let xPosition: CGFloat
    let isCircle: Bool
    let startRotation: Double
    let finalRotation: Double

    init() {
        let hue = Double.random(in: 0...1)
        color = Color(hue: hue, saturation: 0.8, brightness: 0.9)
        size = CGFloat.random(in: 6...14)
        xPosition = CGFloat.random(in: 0...1)
        isCircle = Bool.random()
        startRotation = Double.random(in: -30...30)
        finalRotation = Double.random(in: -360...360)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CelebrationView()
    }
}
