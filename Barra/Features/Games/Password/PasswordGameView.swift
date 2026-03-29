import SwiftUI

/// The main gameplay screen — shown during an active Password game.
///
/// @ObservedObject: receives the ViewModel from PasswordSetupView (the owner).
struct PasswordGameView: View {

    @ObservedObject var gameVM: PasswordViewModel

    var body: some View {
        ZStack {
            BarraTheme.background.ignoresSafeArea()

            switch gameVM.phase {
            case .setup:
                EmptyView()     // handled by PasswordSetupView

            case .roundIntro:
                roundIntroView
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))

            case .playing:
                playingView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .roundEnd:
                roundEndView
                    .transition(.opacity)

            case .gameOver:
                PasswordResultsView(gameVM: gameVM)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: gameVM.phase)
    }

    // MARK: - Round Intro ("Get Ready!")

    private var roundIntroView: some View {
        VStack(spacing: BarraTheme.paddingL) {
            Spacer()

            // Team colour indicator
            ZStack {
                Circle()
                    .fill(teamColor(gameVM.currentTeamIndex).opacity(0.15))
                    .frame(width: 120, height: 120)
                Text(teamEmoji(gameVM.currentTeamIndex))
                    .font(.system(size: 52))
            }

            VStack(spacing: 8) {
                Text(gameVM.currentTeam.name)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(BarraTheme.primary)
                Text("it's your turn")
                    .font(.system(size: 18, design: .rounded))
                    .foregroundStyle(BarraTheme.secondary)
            }

            Text(gameVM.roundLabel)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(BarraTheme.surface)
                .clipShape(Capsule())

            Spacer()

            // Score bar
            scoreBar

            Text("Pass the phone to \(gameVM.currentTeam.name)'s describer — don't let the other team see the word!")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BarraTheme.paddingL)

            BarraButton(title: "I'm Ready — Show Word") {
                withAnimation {
                    gameVM.beginRound()
                }
            }
            .padding(.horizontal, BarraTheme.paddingL)
            .padding(.bottom, BarraTheme.paddingL)
        }
    }

    // MARK: - Playing view

    private var playingView: some View {
        VStack(spacing: 0) {

            // Top bar: round label + score
            VStack(spacing: BarraTheme.paddingS) {
                Text(gameVM.roundLabel)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(BarraTheme.secondary)
                scoreBar
            }
            .padding(.top, BarraTheme.paddingM)
            .padding(.horizontal, BarraTheme.paddingM)

            Spacer()

            // Timer ring
            timerRing

            Spacer()

            // The word — this is what the describer sees
            VStack(spacing: BarraTheme.paddingS) {
                Text("The word is")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(BarraTheme.secondary)

                Text(gameVM.currentWord)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(BarraTheme.primary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.horizontal, BarraTheme.paddingL)
                    .contentTransition(.numericText())   // smooth word transition
            }

            Spacer()

            // Action buttons
            HStack(spacing: BarraTheme.paddingM) {
                // Skip
                Button {
                    withAnimation { gameVM.wordSkipped() }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 22))
                        Text("Skip")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BarraTheme.paddingM)
                    .foregroundStyle(BarraTheme.secondary)
                    .background(BarraTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                            .stroke(BarraTheme.secondary.opacity(0.3), lineWidth: 1)
                    )
                }

                // Got it!
                Button {
                    withAnimation { gameVM.wordGuessed() }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                        Text("Got It!")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BarraTheme.paddingM)
                    .foregroundStyle(.white)
                    .background(Color(red: 0.18, green: 0.65, blue: 0.40))  // success green
                    .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
                }
            }
            .padding(.horizontal, BarraTheme.paddingM)
            .padding(.bottom, BarraTheme.paddingL)
        }
    }

    // MARK: - Round end (brief transition screen)

    private var roundEndView: some View {
        VStack(spacing: BarraTheme.paddingM) {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
                .tint(BarraTheme.accent)
                .scaleEffect(1.2)
            Text("Next round...")
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)
            Spacer()
        }
    }

    // MARK: - Reusable components

    private var scoreBar: some View {
        HStack {
            // Team 1
            HStack(spacing: 6) {
                Text("🔴")
                    .font(.system(size: 16))
                VStack(alignment: .leading, spacing: 2) {
                    Text(gameVM.teams[0].name)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(BarraTheme.secondary)
                    Text("\(gameVM.teams[0].score)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(BarraTheme.primary)
                        .contentTransition(.numericText())
                }
            }

            Spacer()

            // VS
            Text("vs")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)

            Spacer()

            // Team 2
            HStack(spacing: 6) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(gameVM.teams[1].name)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(BarraTheme.secondary)
                    Text("\(gameVM.teams[1].score)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(BarraTheme.primary)
                        .contentTransition(.numericText())
                }
                Text("🔵")
                    .font(.system(size: 16))
            }
        }
        .padding(.horizontal, BarraTheme.paddingL)
        .padding(.vertical, BarraTheme.paddingS)
        .background(BarraTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
        .padding(.horizontal, BarraTheme.paddingM)
        .animation(.spring(response: 0.4), value: gameVM.teams[0].score)
        .animation(.spring(response: 0.4), value: gameVM.teams[1].score)
    }

    private var timerRing: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(BarraTheme.secondary.opacity(0.15), lineWidth: 8)
                .frame(width: 110, height: 110)

            // Progress ring — animates as timeRemaining decreases
            Circle()
                .trim(from: 0, to: gameVM.timerProgress)
                .stroke(
                    timerColor(gameVM.timeRemaining),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 110, height: 110)
                .rotationEffect(.degrees(-90))  // start from the top
                .animation(.linear(duration: 1), value: gameVM.timeRemaining)

            // Time number
            VStack(spacing: 2) {
                Text("\(gameVM.timeRemaining)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(timerColor(gameVM.timeRemaining))
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.linear(duration: 0.5), value: gameVM.timeRemaining)
                Text("sec")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(BarraTheme.secondary)
            }
        }
    }

    // MARK: - Helpers

    private func timerColor(_ seconds: Int) -> Color {
        switch seconds {
        case 21...: return BarraTheme.accent
        case 11...20: return .orange
        default: return .red
        }
    }

    private func teamColor(_ index: Int) -> Color {
        index == 0 ? .red : .blue
    }

    private func teamEmoji(_ index: Int) -> String {
        index == 0 ? "🔴" : "🔵"
    }
}
