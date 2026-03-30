import SwiftUI

/// Setup screen — pick teams, category, and target score.
struct PasswordSetupView: View {

    @StateObject private var gameVM = PasswordViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            BarraTheme.background.ignoresSafeArea()

            if gameVM.phase == .setup {
                setupContent
            } else {
                PasswordGameView(gameVM: gameVM)
            }
        }
        .navigationTitle("Password")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(gameVM.phase != .setup)
    }

    // MARK: - Setup

    private var setupContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BarraTheme.paddingL) {

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Set up the game")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(BarraTheme.primary)
                    Text("Give one-word clues. First to the target score wins.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(BarraTheme.secondary)
                }
                .staggeredAppearance(index: 0)

                // Teams
                VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
                    sectionLabel("Teams")
                    teamField(index: 0, emoji: "🔴")
                    teamField(index: 1, emoji: "🔵")
                }
                .staggeredAppearance(index: 1)

                // Category picker
                VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
                    sectionLabel("Category")
                    categoryGrid
                }
                .staggeredAppearance(index: 2)

                // Target score
                VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
                    sectionLabel("First to...")
                    scoreOptions
                }
                .staggeredAppearance(index: 3)

                // How to play
                VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
                    sectionLabel("How to play")
                    howToPlayCard
                }
                .staggeredAppearance(index: 4)

                Spacer(minLength: BarraTheme.paddingL)

                BarraButton(title: "Start Game", icon: "play.fill") {
                    gameVM.startGame()
                }
                .staggeredAppearance(index: 5)
                .padding(.bottom, BarraTheme.paddingL)
            }
            .padding(BarraTheme.paddingL)
        }
    }

    // MARK: - Team fields

    @ViewBuilder
    private func teamField(index: Int, emoji: String) -> some View {
        HStack(spacing: BarraTheme.paddingS) {
            Text(emoji)
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

    // MARK: - Category grid

    private var categoryGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: BarraTheme.paddingS),
            GridItem(.flexible(), spacing: BarraTheme.paddingS)
        ], spacing: BarraTheme.paddingS) {
            ForEach(PasswordCategories.all) { category in
                categoryCard(category)
            }
        }
    }

    @ViewBuilder
    private func categoryCard(_ category: WordCategory) -> some View {
        let isSelected = gameVM.selectedCategory.id == category.id

        Button {
            HapticManager.selection()
            withAnimation(.barraSnap) {
                gameVM.selectedCategory = category
            }
        } label: {
            VStack(spacing: 6) {
                Text(category.emoji)
                    .font(.system(size: 28))
                Text(category.name)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? .white : BarraTheme.primary)
                Text("\(category.words.count) words")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(isSelected ? .white.opacity(0.7) : BarraTheme.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? BarraTheme.accent : BarraTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                    .stroke(
                        isSelected ? BarraTheme.accent : BarraTheme.secondary.opacity(0.2),
                        lineWidth: isSelected ? 0 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(BarraPressStyle())
    }

    // MARK: - Score options

    private var scoreOptions: some View {
        HStack(spacing: BarraTheme.paddingS) {
            ForEach([15, 30, 50], id: \.self) { score in
                let isSelected = gameVM.targetScore == score
                Button {
                    HapticManager.selection()
                    withAnimation(.barraSnap) {
                        gameVM.targetScore = score
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text("\(score)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        Text("points")
                            .font(.system(size: 11, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(isSelected ? .white : BarraTheme.primary)
                    .background(isSelected ? BarraTheme.accent : BarraTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                            .stroke(
                                isSelected ? BarraTheme.accent : BarraTheme.secondary.opacity(0.2),
                                lineWidth: isSelected ? 0 : 1
                            )
                    )
                    .scaleEffect(isSelected ? 1.02 : 1.0)
                }
            }
        }
    }

    // MARK: - How to play

    private var howToPlayCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            howToPlayRow(icon: "person.2.fill", text: "Split into 2 teams")
            howToPlayRow(icon: "bubble.left.fill", text: "Describer gives a ONE-WORD clue")
            howToPlayRow(icon: "questionmark.circle.fill", text: "Teammate tries to guess the word")
            howToPlayRow(icon: "arrow.left.arrow.right", text: "Wrong? Other team gets a shot at it")

            Divider()
                .padding(.vertical, 2)

            HStack(spacing: BarraTheme.paddingM) {
                pointBadge(attempt: 1)
                pointBadge(attempt: 2)
                pointBadge(attempt: 3)
            }
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

    @ViewBuilder
    private func pointBadge(attempt: Int) -> some View {
        VStack(spacing: 2) {
            Text("Clue \(attempt)")
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)
            Text("\(pointsForAttempt(attempt))")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(BarraTheme.accent)
            Text("pts")
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(BarraTheme.secondary)
            .tracking(1.5)
    }
}

#Preview {
    NavigationStack {
        PasswordSetupView()
    }
}
