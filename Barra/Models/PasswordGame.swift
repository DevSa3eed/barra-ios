import Foundation

// MARK: - Team

/// One of the two competing teams in a Password game.
struct PasswordTeam: Identifiable, Equatable {
    let id: UUID
    var name: String
    var score: Int

    init(id: UUID = UUID(), name: String, score: Int = 0) {
        self.id = id
        self.name = name
        self.score = score
    }
}

// MARK: - Round Result

/// The outcome of a single round — what the word was and whether the team got it.
struct PasswordRound: Identifiable {
    let id: UUID
    let word: String
    let teamName: String
    let guessed: Bool       // true = got it, false = skipped / ran out of time

    init(id: UUID = UUID(), word: String, teamName: String, guessed: Bool) {
        self.id = id
        self.word = word
        self.teamName = teamName
        self.guessed = guessed
    }
}

// MARK: - Game Phase

/// The current state of the game.
/// This is a state machine — the ViewModel drives transitions between phases.
enum PasswordGamePhase: Equatable {
    case setup                  // Before the game starts
    case roundIntro             // "Get ready — Team 1's turn"
    case playing                // Timer running, word visible
    case roundEnd               // Brief pause between rounds
    case gameOver               // All rounds done, show results
}
