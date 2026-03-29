import SwiftUI

/// A reusable styled button for Barra.
///
/// Usage:
///   BarraButton(title: "Create a Crew") { doSomething() }
///   BarraButton(title: "Join Instead", style: .secondary) { doSomething() }
struct BarraButton: View {

    enum Style {
        case primary    // amber fill
        case secondary  // outline
    }

    let title: String
    var style: Style = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(style == .primary ? .white : BarraTheme.accent)
                .background(
                    style == .primary
                        ? BarraTheme.accent
                        : Color.clear
                )
                .overlay(
                    RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                        .stroke(BarraTheme.accent, lineWidth: style == .secondary ? 1.5 : 0)
                )
                .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        BarraButton(title: "Create a Crew") {}
        BarraButton(title: "Join Instead", style: .secondary) {}
    }
    .padding()
    .background(BarraTheme.background)
}
