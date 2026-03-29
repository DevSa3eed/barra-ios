import Foundation

/// All game logic for the Password game.
///
/// KEY CONCEPTS IN THIS FILE:
///   - @MainActor        → Swift 6 requires UI state to run on the main thread
///   - async/await       → fetching words from a real API (URLSession)
///   - Task              → running async work from a sync context (e.g. a button tap)
///   - Task.sleep        → the async way to count down a timer (no Timer.scheduledTimer)
///   - @StateObject      → this is created and owned by PasswordSetupView
@MainActor
final class PasswordViewModel: ObservableObject {

    // MARK: - Published state (every @Published change re-renders the UI automatically)

    @Published var phase: PasswordGamePhase = .setup
    @Published var teams: [PasswordTeam] = [
        PasswordTeam(name: "Team 1"),
        PasswordTeam(name: "Team 2")
    ]
    @Published var roundCount: Int = 5
    @Published var currentRoundIndex: Int = 0       // which round we're on (0-based)
    @Published var currentTeamIndex: Int = 0        // 0 = team 1's turn, 1 = team 2's turn
    @Published var currentWord: String = ""
    @Published var timeRemaining: Int = 60
    @Published var rounds: [PasswordRound] = []     // history of all rounds played
    @Published var isLoadingWords: Bool = false
    @Published var wordLoadError: String? = nil

    // MARK: - Private state

    private var wordPool: [String] = []             // fetched words, consumed one per round
    private var timerTask: Task<Void, Never>? = nil // handle to cancel the timer

    // MARK: - Computed helpers (derived from state — no extra @Published needed)

    var currentTeam: PasswordTeam { teams[currentTeamIndex] }
    var roundLabel: String { "Round \(currentRoundIndex + 1) of \(roundCount)" }
    var timerProgress: Double { Double(timeRemaining) / 60.0 }  // 1.0 → 0.0 for the ring

    var winner: PasswordTeam? {
        guard phase == .gameOver else { return nil }
        if teams[0].score == teams[1].score { return nil }  // nil = draw
        return teams[0].score > teams[1].score ? teams[0] : teams[1]
    }

    // MARK: - Setup actions

    func updateTeamName(_ name: String, at index: Int) {
        teams[index].name = name
    }

    // MARK: - Game start
    //
    // This is your first real async/await function that calls URLSession.
    // `async` means it can do work without blocking the UI thread.
    // `await` pauses THIS function until the async work finishes, then resumes.

    func startGame() {
        isLoadingWords = true
        wordLoadError = nil

        // Task { } is how you call async code from a regular (non-async) context.
        // Think of it as "launch this async work in the background."
        Task {
            do {
                wordPool = try await fetchWords(count: roundCount * 2 + 5)  // fetch extra as buffer
            } catch {
                // API failed — fall back to our built-in word list silently
                wordPool = Self.fallbackWords.shuffled()
                wordLoadError = nil  // no need to show an error since fallback works
            }

            isLoadingWords = false
            currentRoundIndex = 0
            currentTeamIndex = 0
            rounds = []
            teams[0].score = 0
            teams[1].score = 0
            advanceToNextRound()
        }
    }

    // MARK: - Round lifecycle

    func advanceToNextRound() {
        guard currentRoundIndex < roundCount else {
            phase = .gameOver
            return
        }

        currentWord = nextWord()
        timeRemaining = 60
        phase = .roundIntro
    }

    /// Called when the player taps "Ready!" on the intro screen.
    func beginRound() {
        phase = .playing
        startTimer()
    }

    /// Player's team guessed the word correctly.
    func wordGuessed() {
        cancelTimer()
        teams[currentTeamIndex].score += 1
        recordRound(guessed: true)
        nextTurn()
    }

    /// Player skipped the word (too hard, or timed out).
    func wordSkipped() {
        cancelTimer()
        recordRound(guessed: false)
        nextTurn()
    }

    // MARK: - Timer
    //
    // Instead of Timer.scheduledTimer, we use async/await:
    //   `Task.sleep(for: .seconds(1))` suspends for 1 second without blocking any thread.
    //   The `for` loop ticks down until zero, then calls wordSkipped() automatically.

    private func startTimer() {
        timerTask = Task {
            while timeRemaining > 0 {
                // `try?` means: if the task is cancelled, just stop silently
                try? await Task.sleep(for: .seconds(1))

                // If task was cancelled (because user tapped Got It / Skip), stop here
                if Task.isCancelled { return }

                timeRemaining -= 1
            }
            // Time's up — auto-skip
            if phase == .playing {
                wordSkipped()
            }
        }
    }

    private func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    // MARK: - Private helpers

    private func nextTurn() {
        phase = .roundEnd
        currentRoundIndex += 1
        currentTeamIndex = currentTeamIndex == 0 ? 1 : 0   // alternate teams

        // Small pause before the next round intro
        Task {
            try? await Task.sleep(for: .milliseconds(600))
            advanceToNextRound()
        }
    }

    private func recordRound(guessed: Bool) {
        rounds.append(PasswordRound(
            word: currentWord,
            teamName: currentTeam.name,
            guessed: guessed
        ))
    }

    private func nextWord() -> String {
        if wordPool.isEmpty {
            wordPool = Self.fallbackWords.shuffled()
        }
        return wordPool.removeFirst().capitalized
    }

    // MARK: - Word fetching
    //
    // This is URLSession.data(from:) — the async/await API for network requests.
    // `throws` means it can fail (network error, bad JSON, etc.) — we handle it above.

    private func fetchWords(count: Int) async throws -> [String] {
        let url = URL(string: "https://random-word-api.herokuapp.com/word?number=\(count)&lang=en")!

        // `await` here suspends fetchWords until the network response arrives.
        // The UI stays totally responsive while we wait.
        let (data, response) = try await URLSession.shared.data(from: url)

        // Validate HTTP status
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let words = try JSONDecoder().decode([String].self, from: data)

        // Filter out words that are too short or too long for the game
        return words.filter { $0.count >= 4 && $0.count <= 10 }
    }

    // MARK: - Fallback word list
    //
    // Used when the API is unavailable. 60 crowd-pleasing Password words.

    private static let fallbackWords = [
        "Beach", "Pizza", "Castle", "Tiger", "Guitar",
        "Volcano", "Library", "Dolphin", "Sunset", "Compass",
        "Thunder", "Garden", "Lantern", "Shadow", "Mirror",
        "Fossil", "Jungle", "Blanket", "Candle", "Anchor",
        "Penguin", "Cactus", "Diamond", "Rocket", "Marble",
        "Whisper", "Balloon", "Magnet", "Pyramid", "Feather",
        "Chimney", "Swamp", "Crown", "Hammer", "Tunnel",
        "Compass", "Chimney", "Tornado", "Helmet", "Lantern",
        "Glacier", "Cobweb", "Falcon", "Bucket", "Shovel",
        "Pillow", "Wagon", "Mango", "Statue", "Pebble",
        "Snowflake", "Cabin", "Goblin", "Canoe", "Riddle",
        "Blossom", "Ember", "Velvet", "Harvest", "Cinnamon"
    ]
}
