import SwiftUI

struct GamesView: View {

    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                BarraTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: BarraTheme.paddingL) {

                        // Active games
                        VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
                            sectionLabel("Ready to Play")
                                .staggeredAppearance(index: 0)

                            NavigationLink(destination: PasswordSetupView()) {
                                GameCard(
                                    title: "Password",
                                    subtitle: "Describe the word, one clue at a time",
                                    emoji: "💬",
                                    players: "4+ players",
                                    duration: "~15 min",
                                    isAvailable: true
                                )
                            }
                            .buttonStyle(BarraCardPressStyle())
                            .staggeredAppearance(index: 1)
                        }

                        // Coming soon
                        VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
                            sectionLabel("Coming Soon")
                                .staggeredAppearance(index: 2)

                            GameCard(
                                title: "Mafia",
                                subtitle: "Uncover the mafia before they take over",
                                emoji: "🕵️",
                                players: "6–12 players",
                                duration: "~30 min",
                                isAvailable: false
                            )
                            .staggeredAppearance(index: 3)

                            GameCard(
                                title: "Flip 7",
                                subtitle: "Press your luck — but don't bust",
                                emoji: "🃏",
                                players: "3–8 players",
                                duration: "~20 min",
                                isAvailable: false
                            )
                            .staggeredAppearance(index: 4)
                        }
                    }
                    .padding(BarraTheme.paddingM)
                }
            }
            .navigationTitle("Games")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    @ViewBuilder
    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(BarraTheme.secondary)
            .tracking(1.5)
    }
}

// MARK: - Game Card

struct GameCard: View {
    let title: String
    let subtitle: String
    let emoji: String
    let players: String
    let duration: String
    let isAvailable: Bool

    var body: some View {
        HStack(spacing: BarraTheme.paddingM) {
            // Emoji icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(isAvailable ? BarraTheme.accent.opacity(0.12) : BarraTheme.secondary.opacity(0.08))
                    .frame(width: 60, height: 60)
                Text(emoji)
                    .font(.system(size: 28))
                    .opacity(isAvailable ? 1.0 : 0.5)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(isAvailable ? BarraTheme.primary : BarraTheme.secondary)

                    if !isAvailable {
                        Text("Soon")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(BarraTheme.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(BarraTheme.secondary.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }

                Text(subtitle)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(BarraTheme.secondary)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    Label(players, systemImage: "person.2.fill")
                    Label(duration, systemImage: "clock")
                }
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(BarraTheme.secondary.opacity(0.7))
            }

            Spacer()

            if isAvailable {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(BarraTheme.secondary)
            }
        }
        .padding(BarraTheme.paddingM)
        .background(BarraTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                .stroke(BarraTheme.secondary.opacity(0.2), lineWidth: 1)
        )
        .opacity(isAvailable ? 1.0 : 0.6)
    }
}

#Preview {
    GamesView()
}
