import Foundation

/// All game logic for the Password game.
///
/// GAME RULES (matching "Party Games - Password Game"):
///   1. Two teams compete on the SAME word
///   2. Team A's describer gives a ONE-WORD clue → Team A guesses
///   3. If wrong, Team B's describer gives a clue → Team B guesses
///   4. Up to 3 attempts per word:  Attempt 1 = 6pts, Attempt 2 = 4pts, Attempt 3 = 2pts
///   5. First team to the target score wins (default: 30)
///
/// PHONE FLOW per word:
///   passPhone → showingWord → judging → scored/passPhone(next attempt)/nobodyGotIt
@MainActor
final class PasswordViewModel: ObservableObject {

    // MARK: - Published state

    @Published var phase: PasswordGamePhase = .setup
    @Published var teams: [PasswordTeam] = [
        PasswordTeam(name: "Team 1"),
        PasswordTeam(name: "Team 2")
    ]
    @Published var targetScore: Int = 30
    @Published var selectedCategory: WordCategory = PasswordCategories.general
    @Published var currentWord: String = ""
    @Published var currentAttempt: Int = 1          // 1, 2, or 3
    @Published var currentClueTeamIndex: Int = 0    // which team is giving the clue NOW
    @Published var startingTeamIndex: Int = 0       // which team started this word (alternates)
    @Published var wordResults: [WordResult] = []
    @Published var lastScoredPoints: Int = 0        // for the celebration screen

    // MARK: - Private state

    private var wordPool: [String] = []

    // MARK: - Computed

    var currentTeam: PasswordTeam { teams[currentClueTeamIndex] }
    var pointsAvailable: Int { pointsForAttempt(currentAttempt) }
    var wordsPlayed: Int { wordResults.count }

    var winner: PasswordTeam? {
        guard phase == .gameOver else { return nil }
        // The team that crossed the target first
        return teams.first(where: { $0.score >= targetScore })
    }

    // MARK: - Setup

    func updateTeamName(_ name: String, at index: Int) {
        teams[index].name = name
    }

    // MARK: - Start game

    func startGame() {
        // Shuffle the selected category's words
        wordPool = selectedCategory.words.shuffled()

        // Reset
        teams[0].score = 0
        teams[1].score = 0
        wordResults = []
        startingTeamIndex = 0
        lastScoredPoints = 0

        drawNextWord()
    }

    // MARK: - Word lifecycle

    /// Draw a new word and prepare for the first clue attempt.
    private func drawNextWord() {
        // Check if anyone has won
        if let winnerIdx = teams.firstIndex(where: { $0.score >= targetScore }) {
            phase = .gameOver
            HapticManager.success()
            return
        }

        // Refill if needed
        if wordPool.isEmpty {
            wordPool = selectedCategory.words.shuffled()
        }

        currentWord = wordPool.removeFirst()
        currentAttempt = 1
        currentClueTeamIndex = startingTeamIndex

        // Alternate which team starts each word
        startingTeamIndex = startingTeamIndex == 0 ? 1 : 0

        phase = .passPhone
    }

    /// Called when the describer taps "I'm ready" — show them the word.
    func showWord() {
        phase = .showingWord
    }

    /// Called after the describer gives their verbal clue — now judge the guess.
    func clueGiven() {
        phase = .judging
        HapticManager.light()
    }

    /// The guesser got it right!
    func guessedCorrectly() {
        let points = pointsAvailable
        teams[currentClueTeamIndex].score += points
        lastScoredPoints = points

        wordResults.append(WordResult(
            word: currentWord,
            scoredByTeam: currentTeam.name,
            points: points,
            clueAttempts: currentAttempt
        ))

        HapticManager.doubleTap()
        phase = .scored

        // After a brief pause, move to next word
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            drawNextWord()
        }
    }

    /// The guesser got it wrong.
    func guessedWrong() {
        HapticManager.light()

        if currentAttempt < 3 {
            // Move to next attempt — other team gets a shot
            currentAttempt += 1
            currentClueTeamIndex = currentClueTeamIndex == 0 ? 1 : 0
            phase = .passPhone
        } else {
            // All 3 attempts used — nobody got it
            wordResults.append(WordResult(
                word: currentWord,
                scoredByTeam: nil,
                points: 0,
                clueAttempts: 3
            ))

            phase = .nobodyGotIt

            Task {
                try? await Task.sleep(for: .seconds(1.5))
                drawNextWord()
            }
        }
    }
}
