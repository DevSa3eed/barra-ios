import SwiftUI

// MARK: - Animation Presets

/// Reusable animation curves used throughout Barra.
/// Keeps motion consistent and easy to tweak from one place.
extension Animation {

    /// Default spring for interactive elements (buttons, cards, toggles).
    static let barraBounce = Animation.spring(response: 0.35, dampingFraction: 0.7)

    /// Quick spring for small UI changes (opacity, selection highlights).
    static let barraSnap = Animation.spring(response: 0.2, dampingFraction: 0.8)

    /// Gentle ease for ambient animations (floating, glowing).
    static let barraGentle = Animation.easeInOut(duration: 0.5)

    /// Stagger animation with a per-item delay.
    static func barraStagger(index: Int, baseDelay: Double = 0.05) -> Animation {
        .spring(response: 0.45, dampingFraction: 0.75).delay(Double(index) * baseDelay)
    }
}

// MARK: - Press Button Style

/// A button style that scales down and dims on press — makes any button feel alive.
///
/// Usage:
///   Button("Tap me") { ... }
///       .buttonStyle(BarraPressStyle())
struct BarraPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.barraSnap, value: configuration.isPressed)
    }
}

// MARK: - Card Press Style

/// Press style for larger interactive cards (games list, crew card).
/// Slightly more travel and a subtle shadow lift.
struct BarraCardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.975 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .shadow(
                color: BarraTheme.primary.opacity(configuration.isPressed ? 0 : 0.06),
                radius: configuration.isPressed ? 0 : 8,
                y: configuration.isPressed ? 0 : 4
            )
            .animation(.barraSnap, value: configuration.isPressed)
    }
}

// MARK: - Staggered Appearance Modifier

/// Makes a view appear with a slide-up + fade-in, delayed by its index.
///
/// Usage:
///   ForEach(items.indices, id: \.self) { index in
///       ItemView(...)
///           .staggeredAppearance(index: index)
///   }
struct StaggeredAppearance: ViewModifier {
    let index: Int
    let baseDelay: Double
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .offset(y: appeared ? 0 : 20)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.barraStagger(index: index, baseDelay: baseDelay)) {
                    appeared = true
                }
            }
    }
}

extension View {
    func staggeredAppearance(index: Int, baseDelay: Double = 0.06) -> some View {
        modifier(StaggeredAppearance(index: index, baseDelay: baseDelay))
    }
}

// MARK: - Shimmer Modifier

/// Adds a subtle shine sweep across a view — great for "premium" feel on titles.
///
/// Usage:
///   Text("BARRA")
///       .barraShimmer()
struct BarraShimmer: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.15), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: geo.size.width * phase)
                    .onAppear {
                        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                            phase = 1.5
                        }
                    }
                }
            )
            .clipped()
    }
}

extension View {
    func barraShimmer() -> some View {
        modifier(BarraShimmer())
    }
}
