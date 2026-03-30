import SwiftUI

/// The main gameplay screen — pass-the-phone clue/guess flow.
struct PasswordGameView: View {

    @ObservedObject var gameVM: PasswordViewModel

    // Word reveal animation
    @State private var wordRevealed = false

    var body: some View {
        ZStack {
            BarraTheme.background.ignoresSafeArea()

            switch gameVM.phase {
            case .setup:
                EmptyView()

            case .passPhone:
                passPhoneView
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))

            case .showingWord:
                showingWordView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))

            case .judging:
                judgingView
                    .transition(.opacity)

            case .scored:
                scoredView
                    .transition(.scale(scale: 0.8).combined(with: .opacity))

            case .nobodyGotIt:
                nobodyGotItView
                    .transition(.opacity)

            case .gameOver:
                PasswordResultsView(gameVM: gameVM)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: gameVM.phase)
    }

    // MARK: - Pass Phone Screen
    // "Pass the phone to [Team]'s describer — don't peek!"

    private var passPhoneView: some View {
        VStack(spacing: BarraTheme.paddingL) {
            Spacer()

            // Score bar at top
            scoreBar
                .staggeredAppearance(index: 0)

            Spacer()

            // Team indicator
            ZStack {
                Circle()
                    .fill(teamColor(gameVM.currentClueTeamIndex).opacity(0.08))
                    .frame(width: 160, height: 160)
                Circle()
                    .fill(teamColor(gameVM.currentClueTeamIndex).opacity(0.15))
                    .frame(width: 120, height: 120)
                Text(teamEmoji(gameVM.currentClueTeamIndex))
                    .font(.system(size: 56))
            }
            .staggeredAppearance(index: 1)

            VStack(spacing: 8) {
                Text(gameVM.currentTeam.name)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(BarraTheme.primary)
                Text("your turn to give a clue")
                    .font(.system(size: 17, design: .rounded))
                    .foregroundStyle(BarraTheme.secondary)
            }
            .staggeredAppearance(index: 2)

            // Attempt badge
            attemptBadge
                .staggeredAppearance(index: 3)

            Spacer()

            Text("Pass the phone to \(gameVM.currentTeam.name)'s describer.\nNo peeking!")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BarraTheme.paddingL)

            BarraButton(title: "I'm the Describer — Show Word", icon: "eye.fill") {
                wordRevealed = false
                gameVM.showWord()
                // Animate word reveal
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.15)) {
                    wordRevealed = true
                }
            }
            .padding(.horizontal, BarraTheme.paddingL)
            .padding(.bottom, BarraTheme.paddingL)
        }
    }

    // MARK: - Showing Word Screen
    // Describer sees the word and gives a ONE-WORD verbal clue

    private var showingWordView: some View {
        VStack(spacing: 0) {

            // Top: score + attempt info
            VStack(spacing: BarraTheme.paddingS) {
                scoreBar
                attemptBadge
            }
            .padding(.top, BarraTheme.paddingM)

            Spacer()

            // The word
            VStack(spacing: BarraTheme.paddingS) {
                Text("THE WORD IS")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(BarraTheme.secondary)
                    .tracking(2)

                Text(gameVM.currentWord)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(BarraTheme.primary)
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                    .padding(.horizontal, BarraTheme.paddingL)
                    .scaleEffect(wordRevealed ? 1.0 : 0.3)
                    .opacity(wordRevealed ? 1.0 : 0)

                Text("Give a ONE-WORD clue out loud")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(BarraTheme.accent)
                    .padding(.top, 4)
            }

            Spacer()

            // Rules reminder
            VStack(spacing: 4) {
                Label("No rhyming, no sounds, no gestures", systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(BarraTheme.secondary.opacity(0.7))
                Label("Only ONE word per clue", systemImage: "1.circle.fill")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(BarraTheme.secondary.opacity(0.7))
            }

            BarraButton(title: "I Gave My Clue", icon: "checkmark") {
                gameVM.clueGiven()
            }
            .padding(.horizontal, BarraTheme.paddingL)
            .padding(.bottom, BarraTheme.paddingL)
        }
    }

    // MARK: - Judging Screen
    // "Did [Team] guess correctly?"

    private var judgingView: some View {
        VStack(spacing: 0) {

            // Top
            VStack(spacing: BarraTheme.paddingS) {
                scoreBar
                attemptBadge
            }
            .padding(.top, BarraTheme.paddingM)

            Spacer()

            // Word (still visible for the describer to judge)
            VStack(spacing: BarraTheme.paddingM) {
                Text(gameVM.currentWord)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(BarraTheme.primary)
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                    .padding(.horizontal, BarraTheme.paddingL)

                Text("Did \(gameVM.currentTeam.name) guess it?")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(BarraTheme.secondary)
            }

            Spacer()

            // Correct / Wrong buttons
            HStack(spacing: BarraTheme.paddingM) {
                // Wrong
                Button {
                    withAnimation { gameVM.guessedWrong() }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                        Text("Wrong")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .foregroundStyle(.white)
                    .background(Color(red: 0.75, green: 0.25, blue: 0.25))
                    .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
                }
                .buttonStyle(BarraPressStyle())

                // Correct
                Button {
                    withAnimation { gameVM.guessedCorrectly() }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                        Text("Correct!")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .foregroundStyle(.white)
                    .background(Color(red: 0.18, green: 0.65, blue: 0.40))
                    .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
                }
                .buttonStyle(BarraPressStyle())
            }
            .padding(.horizontal, BarraTheme.paddingM)
            .padding(.bottom, BarraTheme.paddingL)
        }
    }

    // MARK: - Scored! Celebration

    private var scoredView: some View {
        VStack(spacing: BarraTheme.paddingM) {
            Spacer()

            Text("✅")
                .font(.system(size: 72))
                .scaleEffect(1.0)
                .transition(.scale(scale: 0.3).combined(with: .opacity))

            Text(gameVM.currentTeam.name)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(BarraTheme.primary)

            Text("+\(gameVM.lastScoredPoints) points!")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(BarraTheme.accent)
                .contentTransition(.numericText())

            scoreBar
                .padding(.top, BarraTheme.paddingM)

            Spacer()
        }
    }

    // MARK: - Nobody Got It

    private var nobodyGotItView: some View {
        VStack(spacing: BarraTheme.paddingM) {
            Spacer()

            Text("😬")
                .font(.system(size: 72))

            Text("Nobody got it!")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(BarraTheme.primary)

            Text("The word was")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)

            Text(gameVM.currentWord)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(BarraTheme.accent)

            scoreBar
                .padding(.top, BarraTheme.paddingM)

            Spacer()
        }
    }

    // MARK: - Reusable components

    private var scoreBar: some View {
        HStack {
            HStack(spacing: 6) {
                Text("🔴").font(.system(size: 16))
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

            // Target score indicator
            VStack(spacing: 2) {
                Text("First to")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(BarraTheme.secondary)
                Text("\(gameVM.targetScore)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(BarraTheme.accent)
            }

            Spacer()

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
                Text("🔵").font(.system(size: 16))
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

    private var attemptBadge: some View {
        HStack(spacing: BarraTheme.paddingM) {
            ForEach(1...3, id: \.self) { attempt in
                let isCurrent = attempt == gameVM.currentAttempt
                let isPast = attempt < gameVM.currentAttempt

                VStack(spacing: 4) {
                    Text("\(pointsForAttempt(attempt))")
                        .font(.system(size: isCurrent ? 24 : 16, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            isCurrent ? BarraTheme.accent :
                            isPast ? BarraTheme.secondary.opacity(0.3) :
                            BarraTheme.secondary.opacity(0.5)
                        )
                    Text("pts")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(BarraTheme.secondary.opacity(isCurrent ? 1 : 0.4))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    isCurrent ? BarraTheme.accent.opacity(0.1) : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isCurrent ? BarraTheme.accent.opacity(0.3) : Color.clear,
                            lineWidth: 1
                        )
                )
                .animation(.barraSnap, value: gameVM.currentAttempt)
            }
        }
        .padding(.horizontal, BarraTheme.paddingL)
    }

    // MARK: - Helpers

    private func teamColor(_ index: Int) -> Color {
        index == 0 ? .red : .blue
    }

    private func teamEmoji(_ index: Int) -> String {
        index == 0 ? "🔴" : "🔵"
    }
}
