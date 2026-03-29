import SwiftUI

/// The setup screen before a Password game begins.
/// Creates and OWNS the PasswordViewModel — @StateObject lives here.
struct PasswordSetupView: View {

    // @StateObject: this view CREATES the ViewModel.
    // It survives re-renders of PasswordSetupView without being reset.
    @StateObject private var gameVM = PasswordViewModel()

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            BarraTheme.background.ignoresSafeArea()

            // Show loading spinner while words are being fetched
            if gameVM.isLoadingWords {
                loadingView
            } else if gameVM.phase == .setup {
                setupContent
            } else {
                // Game has started — show the game view
                PasswordGameView(gameVM: gameVM)
            }
        }
        .navigationTitle("Password")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(gameVM.phase != .setup)
    }

    // MARK: - Setup content

    private var setupContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BarraTheme.paddingL) {

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Set up the game")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(BarraTheme.primary)
                    Text("Two teams, one word. Describe it without saying it.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(BarraTheme.secondary)
                }

                // Team names
                VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
                    sectionLabel("Teams")

                    VStack(spacing: BarraTheme.paddingS) {
                        teamField(index: 0, icon: "🔴")
                        teamField(index: 1, icon: "🔵")
                    }
                }

                // Rounds picker
                VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
                    sectionLabel("Rounds")

                    HStack(spacing: BarraTheme.paddingS) {
                        ForEach([3, 5, 7, 10], id: \.self) { count in
                            roundOption(count)
                        }
                    }
                }

                // How to play
                VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
                    sectionLabel("How to play")
                    howToPlayCard
                }

                Spacer(minLength: BarraTheme.paddingL)

                BarraButton(title: "Start Game") {
                    gameVM.startGame()
                }
                .padding(.bottom, BarraTheme.paddingL)
            }
            .padding(BarraTheme.paddingL)
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(BarraTheme.secondary)
            .tracking(1.5)
    }

    @ViewBuilder
    private func teamField(index: Int, icon: String) -> some View {
        HStack(spacing: BarraTheme.paddingS) {
            Text(icon)
                .font(.system(size: 24))
                .frame(width: 40)

            TextField("Team \(index + 1) name", text: Binding(
                get: { gameVM.teams[index].name },
                set: { gameVM.updateTeamName($0, at: index) }
            ))
            .font(.system(size: 16, design: .rounded))
            .padding(BarraTheme.paddingM)
            .background(BarraTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                    .stroke(BarraTheme.secondary.opacity(0.3), lineWidth: 1)
            )
        }
    }

    @ViewBuilder
    private func roundOption(_ count: Int) -> some View {
        let selected = gameVM.roundCount == count
        Button {
            withAnimation(.spring(response: 0.3)) {
                gameVM.roundCount = count
            }
        } label: {
            Text("\(count)")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(selected ? .white : BarraTheme.primary)
                .background(selected ? BarraTheme.accent : BarraTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            selected ? BarraTheme.accent : BarraTheme.secondary.opacity(0.3),
                            lineWidth: 1
                        )
                )
        }
    }

    private var howToPlayCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            howToPlayRow(icon: "eye.slash.fill", text: "One person sees the word — keep it hidden from your team")
            howToPlayRow(icon: "bubble.left.fill", text: "Give one-word clues until your team guesses it")
            howToPlayRow(icon: "timer", text: "60 seconds per round — tap Got It! or Skip")
            howToPlayRow(icon: "trophy.fill", text: "Most points after all rounds wins")
        }
        .padding(BarraTheme.paddingM)
        .background(BarraTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
    }

    @ViewBuilder
    private func howToPlayRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(BarraTheme.accent)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)
        }
    }

    private var loadingView: some View {
        VStack(spacing: BarraTheme.paddingM) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(BarraTheme.accent)
                .scaleEffect(1.4)
            Text("Loading words...")
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        PasswordSetupView()
    }
}
