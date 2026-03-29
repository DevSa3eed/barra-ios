import Foundation

/// The single source of truth for the Crew feature.
///
/// @MainActor is required in Swift 6: any class that publishes UI state
/// must run on the main thread. The compiler enforces this.
///
/// HOW TO USE:
///   - Create once with @StateObject in ContentView (the owner)
///   - Pass down with @ObservedObject to every Crew sub-view (the observers)
@MainActor
final class CrewViewModel: ObservableObject {

    // MARK: - Published state
    //
    // `private(set)` means views can READ this freely, but only
    // this ViewModel can WRITE it. This prevents accidental mutation
    // from inside a view — a common SwiftUI bug.
    @Published private(set) var currentCrew: Crew?

    // MARK: - Storage
    private let storageKey = "barra.currentCrew"

    // MARK: - Init
    init() {
        // Load any previously saved crew immediately on startup
        currentCrew = loadCrew()
    }

    // MARK: - Intent methods
    //
    // Named as user actions ("createCrew", "joinCrew", "leaveCrew"),
    // not technical operations ("saveToDisk", "updateState").
    // Views call these and don't need to know how persistence works.

    /// Creates a new crew and saves it locally.
    func createCrew(name: String, yourName: String) {
        let you = Player(name: yourName)
        let crew = Crew(
            name: name,
            inviteCode: generateCode(),
            members: [you]
        )
        currentCrew = crew
        saveCrew(crew)
    }

    /// Joins an existing crew by invite code.
    /// Returns `false` if the code format is invalid (not exactly 6 chars).
    @discardableResult
    func joinCrew(code: String, yourName: String) -> Bool {
        let trimmed = code.trimmingCharacters(in: .whitespaces).uppercased()
        guard trimmed.count == 6 else { return false }

        // In a real app this would hit a server. For now we simulate it locally.
        let you = Player(name: yourName)
        let crew = Crew(
            name: "The Crew",       // server would return the real name
            inviteCode: trimmed,
            members: [you]
        )
        currentCrew = crew
        saveCrew(crew)
        return true
    }

    /// Removes the saved crew and returns to the empty state.
    func leaveCrew() {
        currentCrew = nil
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    // MARK: - Private helpers

    /// Generates a random 6-character alphanumeric code (e.g. "XK92BQ").
    private func generateCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }

    /// Encodes the crew to JSON and saves it in UserDefaults.
    /// Week 4: replace these two functions with SwiftData — everything else stays the same.
    private func saveCrew(_ crew: Crew) {
        if let encoded = try? JSONEncoder().encode(crew) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    /// Loads and decodes the crew from UserDefaults. Returns nil if nothing is saved.
    private func loadCrew() -> Crew? {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let crew = try? JSONDecoder().decode(Crew.self, from: data)
        else { return nil }
        return crew
    }
}
