import SwiftUI

/// End-of-game screen — winner announcement, final scores, round history.
struct PasswordResultsView: View {

    @ObservedObject var gameVM: PasswordViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showTrophy = false
    @State private var showScores = false
    @State private var showHistory = false
    @State private var trophyScale: CGFloat = 0.3

    var body: some View {
        ScrollView {
            VStack(spacing: BarraTheme.paddingL) {

                // Winner banner
                winnerBanner
                    .padding(.top, BarraTheme.paddingL)

                // Final scores
                if showScores {
                    scoreCards
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Round history
                if showHistory {
                    roundHistory
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Buttons
                if showHistory {
                    actionButtons
                        .transition(.opacity)
                        .padding(.bottom, BarraTheme.paddingL)
                }
            }
            .padding(.horizontal, BarraTheme.paddingM)
        }
        .background(BarraTheme.background.ignoresSafeArea())
        .onAppear {
            // Trophy drop
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.15)) {
                showTrophy = true
                trophyScale = 1.0
            }
            // Score reveal
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
                showScores = true
            }
            // History
            withAnimation(.spring(response: 0.5).delay(0.9)) {
                showHistory = true
            }
            // Haptic
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                HapticManager.success()
            }
        }
    }

    // MARK: - Winner banner

    private var winnerBanner: some View {
        VStack(spacing: BarraTheme.paddingM) {
            if let winner = gameVM.winner {
                VStack(spacing: 12) {
                    Text("🏆")
                        .font(.system(size: 72))
                        .scaleEffect(trophyScale)
                        .opacity(showTrophy ? 1 : 0)

                    Text(winner.name)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(BarraTheme.primary)
                        .barraShimmer()

                    Text("wins!")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .foregroundStyle(BarraTheme.accent)
                }
            } else {
                VStack(spacing: 12) {
                    Text("🤝")
                        .font(.system(size: 72))
                        .scaleEffect(trophyScale)
                        .opacity(showTrophy ? 1 : 0)

                    Text("It's a Draw!")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(BarraTheme.primary)
                        .barraShimmer()

                    Text("Well played, both teams")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundStyle(BarraTheme.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(BarraTheme.paddingL)
        .background(BarraTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
    }

    // MARK: - Score cards

    private var scoreCards: some View {
        HStack(spacing: BarraTheme.paddingM) {
            ForEach(Array(gameVM.teams.enumerated()), id: \.element.id) { index, team in
                scoreCard(team: team, index: index)
                    .staggeredAppearance(index: index, baseDelay: 0.15)
            }
        }
    }

    @ViewBuilder
    private func scoreCard(team: PasswordTeam, index: Int) -> some View {
        let isWinner = gameVM.winner?.id == team.id

        VStack(spacing: 8) {
            Text(index == 0 ? "🔴" : "🔵")
                .font(.system(size: 28))

            Text(team.name)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(BarraTheme.primary)
                .multilineTextAlignment(.center)

            Text("\(team.score)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(isWinner ? BarraTheme.accent : BarraTheme.primary)
                .contentTransition(.numericText())

            Text("point\(team.score == 1 ? "" : "s")")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)

            if isWinner {
                Text("WINNER")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(BarraTheme.accent)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(BarraTheme.paddingM)
        .background(isWinner ? BarraTheme.accent.opacity(0.08) : BarraTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                .stroke(
                    isWinner ? BarraTheme.accent.opacity(0.4) : BarraTheme.secondary.opacity(0.2),
                    lineWidth: isWinner ? 1.5 : 1
                )
        )
    }

    // MARK: - Round history

    private var roundHistory: some View {
        VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
            Text("ROUND HISTORY")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)
                .tracking(1.5)

            VStack(spacing: 0) {
                ForEach(Array(gameVM.rounds.enumerated()), id: \.element.id) { index, round in
                    HStack {
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(BarraTheme.secondary)
                            .frame(width: 24)

                        Text(round.word)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(BarraTheme.primary)

                        Spacer()

                        Text(round.teamName)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(BarraTheme.secondary)

                        Image(systemName: round.guessed ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(round.guessed ? Color(red: 0.18, green: 0.65, blue: 0.40) : BarraTheme.secondary.opacity(0.5))
                            .font(.system(size: 18))
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, BarraTheme.paddingM)
                    .staggeredAppearance(index: index, baseDelay: 0.04)

                    if index < gameVM.rounds.count - 1 {
                        Divider().padding(.leading, 44)
                    }
                }
            }
            .background(BarraTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                    .stroke(BarraTheme.secondary.opacity(0.2), lineWidth: 1)
            )
        }
    }

    // MARK: - Action buttons

    private var actionButtons: some View {
        VStack(spacing: BarraTheme.paddingS) {
            BarraButton(title: "Play Again", icon: "arrow.counterclockwise") {
                gameVM.startGame()
            }
            BarraButton(title: "Done", style: .secondary) {
                dismiss()
            }
        }
    }
}
