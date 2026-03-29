import SwiftUI

/// An animated crescent moon with twinkling stars.
///
/// Built entirely in SwiftUI — no image assets needed.
/// Scales perfectly on all devices and supports dark mode.
///
/// Usage:
///   BarraMoonScene(moonSize: 80)     // default for empty states
///   BarraMoonScene(moonSize: 50)     // compact version
struct BarraMoonScene: View {
    var moonSize: CGFloat = 80
    var sceneWidth: CGFloat = 200
    var sceneHeight: CGFloat = 180

    @State private var moonFloat: CGFloat = 0
    @State private var glowPulse: CGFloat = 0.15

    var body: some View {
        ZStack {
            // Ambient glow behind the moon
            Circle()
                .fill(
                    RadialGradient(
                        colors: [BarraTheme.accent.opacity(glowPulse), .clear],
                        center: .center,
                        startRadius: moonSize * 0.3,
                        endRadius: moonSize * 1.6
                    )
                )
                .frame(width: moonSize * 3, height: moonSize * 3)
                .offset(y: moonFloat)

            // Stars
            starField

            // Crescent moon
            crescentMoon
                .offset(y: moonFloat)
        }
        .frame(width: sceneWidth, height: sceneHeight)
        .onAppear {
            // Gentle floating motion
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                moonFloat = -10
            }
            // Ambient glow pulse
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                glowPulse = 0.25
            }
        }
    }

    // MARK: - Crescent Moon

    private var crescentMoon: some View {
        ZStack {
            // Moon body
            Circle()
                .fill(
                    LinearGradient(
                        colors: [BarraTheme.accent, BarraTheme.accent.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: moonSize, height: moonSize)

            // Shadow circle that creates the crescent shape
            Circle()
                .fill(BarraTheme.background)
                .frame(width: moonSize * 0.78, height: moonSize * 0.78)
                .offset(x: moonSize * 0.22, y: -moonSize * 0.12)
        }
    }

    // MARK: - Star Field

    private var starField: some View {
        ZStack {
            // Scatter stars around the moon — each with its own twinkle animation
            TwinkleStar(size: 3.0, delay: 0.0)
                .offset(x: -70, y: -50)
            TwinkleStar(size: 2.0, delay: 0.4)
                .offset(x: 50, y: -60)
            TwinkleStar(size: 2.5, delay: 0.9)
                .offset(x: -40, y: -75)
            TwinkleStar(size: 1.5, delay: 1.3)
                .offset(x: 70, y: -30)
            TwinkleStar(size: 2.0, delay: 0.6)
                .offset(x: -65, y: 15)
            TwinkleStar(size: 3.0, delay: 0.2)
                .offset(x: 30, y: -80)
            TwinkleStar(size: 1.5, delay: 1.0)
                .offset(x: -20, y: -90)
            TwinkleStar(size: 2.5, delay: 1.5)
                .offset(x: 80, y: -60)
            TwinkleStar(size: 1.5, delay: 0.7)
                .offset(x: -80, y: -35)
            TwinkleStar(size: 2.0, delay: 1.1)
                .offset(x: 60, y: 10)
        }
    }
}

// MARK: - Twinkling Star

/// A single star that pulses in and out with a random rhythm.
///
/// Each star has its own independent animation — the `delay` offsets them
/// so they don't all twinkle in sync (which would look mechanical).
struct TwinkleStar: View {
    let size: CGFloat
    let delay: Double

    @State private var opacity: Double = 0.2

    var body: some View {
        Circle()
            .fill(BarraTheme.accent)
            .frame(width: size, height: size)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 1.8...2.8))
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    opacity = 1.0
                }
            }
    }
}

// MARK: - Preview

#Preview("Moon Scene") {
    ZStack {
        BarraTheme.background.ignoresSafeArea()
        BarraMoonScene()
    }
}

#Preview("Moon Scene Dark") {
    ZStack {
        Color(red: 0.1, green: 0.09, blue: 0.075).ignoresSafeArea()
        BarraMoonScene()
    }
    .preferredColorScheme(.dark)
}
