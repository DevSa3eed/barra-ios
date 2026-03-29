import SwiftUI

/// A reusable styled button for Barra — with press animation and haptic feedback.
///
/// Usage:
///   BarraButton(title: "Create a Crew") { doSomething() }
///   BarraButton(title: "Join Instead", style: .secondary) { doSomething() }
///   BarraButton(title: "Leave", style: .destructive) { doSomething() }
struct BarraButton: View {

    enum Style {
        case primary    // amber fill
        case secondary  // outline
        case destructive // red outline
    }

    let title: String
    var style: Style = .primary
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.medium()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                    .stroke(borderColor, lineWidth: style != .primary ? 1.5 : 0)
            )
            .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
        }
        .buttonStyle(BarraPressStyle())
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:     return .white
        case .secondary:   return BarraTheme.accent
        case .destructive: return .red
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:     return BarraTheme.accent
        case .secondary:   return .clear
        case .destructive: return .clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary:     return .clear
        case .secondary:   return BarraTheme.accent
        case .destructive: return .red.opacity(0.5)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        BarraButton(title: "Create a Crew", icon: "plus") {}
        BarraButton(title: "Join Instead", style: .secondary) {}
        BarraButton(title: "Leave Crew", style: .destructive, icon: "arrow.left") {}
    }
    .padding()
    .background(BarraTheme.background)
}
