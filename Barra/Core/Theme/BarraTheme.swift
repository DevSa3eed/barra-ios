import SwiftUI

enum BarraTheme {
    // MARK: - Colors
    /// Primary sand/warm background
    static let background = Color("BarraBackground")
    /// Deep warm brown — headings, primary text
    static let primary = Color("BarraPrimary")
    /// Muted sand — secondary text, subtitles
    static let secondary = Color("BarraSecondary")
    /// Warm amber — buttons, highlights, tint
    static let accent = Color("BarraAccent")
    /// Off-white card surface
    static let surface = Color("BarraSurface")

    // MARK: - Typography
    static func title(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(primary)
    }

    static func headline(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(primary)
    }

    static func body(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .foregroundStyle(secondary)
    }

    // MARK: - Spacing
    static let paddingS: CGFloat = 8
    static let paddingM: CGFloat = 16
    static let paddingL: CGFloat = 24
    static let cornerRadius: CGFloat = 16
}
