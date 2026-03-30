import SwiftUI

/// End-of-game screen — winner announcement, scores, word history.
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

                // Winner
                winnerBanner
                    .padding(.top, BarraTheme.paddingL)

                // Scores
                if showScores {
                    scoreCards
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Stats
                if showScores {
                    statsRow
                        .transition(.opacity)
                }

                // Word history
                if showHistory {
                    wordHistory
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
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.15)) {
                showTrophy = true
                trophyScale = 1.0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
                showScores = true
            }
            withAnimation(.spring(response: 0.5).delay(0.9)) {
                showHistory = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                HapticManager.success()
            }
        }
    }

    // MARK: - Winner

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

                    Text("reaches \(winner.score) points!")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(BarraTheme.accent)
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
                    Text("points")
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
                .staggeredAppearance(index: index, baseDelay: 0.15)
            }
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        let totalWords = gameVM.wordResults.count
        let scored = gameVM.wordResults.filter { $0.points > 0 }.count
        let firstClue = gameVM.wordResults.filter { $0.clueAttempts == 1 && $0.points > 0 }.count

        return HStack(spacing: BarraTheme.paddingM) {
            statItem(value: "\(totalWords)", label: "Words")
            statItem(value: "\(scored)/\(totalWords)", label: "Guessed")
            statItem(value: "\(firstClue)", label: "First try")
        }
        .padding(BarraTheme.paddingM)
        .background(BarraTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
    }

    @ViewBuilder
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(BarraTheme.primary)
            Text(label)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Word history

    private var wordHistory: some View {
        VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
            Text("WORD HISTORY")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)
                .tracking(1.5)

            VStack(spacing: 0) {
                ForEach(Array(gameVM.wordResults.enumerated()), id: \.element.id) { index, result in
                    HStack {
                        Text(result.word)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(BarraTheme.primary)

                        Spacer()

                        if let team = result.scoredByTeam {
                            Text(team)
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(BarraTheme.secondary)

                            Text("+\(result.points)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(BarraTheme.accent)
                                .frame(width: 30, alignment: .trailing)
                        } else {
                            Text("—")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(BarraTheme.secondary.opacity(0.5))
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, BarraTheme.paddingM)

                    if index < gameVM.wordResults.count - 1 {
                        Divider().padding(.leading, BarraTheme.paddingM)
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

    // MARK: - Buttons

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
