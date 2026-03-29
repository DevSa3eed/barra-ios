import Foundation
import SwiftData

/// The single source of truth for all Crew and Event data.
///
/// WEEK 4 CHANGE: UserDefaults replaced with SwiftData.
/// Only the private persistence methods changed — every other
/// part of this file (intent methods, @Published state, the rule
/// about @StateObject vs @ObservedObject) stayed exactly the same.
/// That's the payoff of keeping persistence behind intent methods.
///
/// HOW SwiftData WORKS HERE:
///   - ModelContext is the "workspace" — insert, delete, fetch, save all go through it.
///   - Changes aren't written to disk until you call modelContext.save().
///   - Fetching uses FetchDescriptor<ModelType> — like a typed database query.
@MainActor
final class CrewViewModel: ObservableObject {

    // MARK: - Dependencies
    private let modelContext: ModelContext

    // MARK: - Published state
    @Published private(set) var currentCrew: Crew?

    // MARK: - Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        currentCrew = fetchCrew()   // load any previously saved crew on startup
    }

    // MARK: - Crew intent methods

    func createCrew(name: String, yourName: String) {
        let player = Player(name: yourName)
        let crew = Crew(name: name, inviteCode: generateCode())
        crew.members.append(player)

        // `insert` registers the object with the context.
        // SwiftData automatically handles the player too via the relationship.
        modelContext.insert(crew)
        save()
        currentCrew = crew
    }

    @discardableResult
    func joinCrew(code: String, yourName: String) -> Bool {
        let trimmed = code.trimmingCharacters(in: .whitespaces).uppercased()
        guard trimmed.count == 6 else { return false }

        let player = Player(name: yourName)
        let crew = Crew(name: "The Crew", inviteCode: trimmed)
        crew.members.append(player)
        modelContext.insert(crew)
        save()
        currentCrew = crew
        return true
    }

    func leaveCrew() {
        guard let crew = currentCrew else { return }
        // `delete` removes the crew AND all its members/events
        // because of `deleteRule: .cascade` on the relationships.
        modelContext.delete(crew)
        save()
        currentCrew = nil
    }

    // MARK: - Event intent methods

    func scheduleEvent(title: String, date: Date, location: String, notes: String) {
        guard let crew = currentCrew else { return }
        let event = GameEvent(title: title, date: date, location: location, notes: notes)
        event.crew = crew
        crew.events.append(event)
        modelContext.insert(event)
        save()
        // Notify observers — SwiftData mutated a @Model property,
        // so we nudge ObservableObject's publisher to re-render dependent views.
        objectWillChange.send()
    }

    func deleteEvent(_ event: GameEvent) {
        modelContext.delete(event)
        save()
        objectWillChange.send()
    }

    func rsvp(to event: GameEvent, status: RSVPStatus) {
        // The "current user" is the first member of the crew —
        // the person who created or joined on this device.
        guard let currentPlayer = currentCrew?.members.first else { return }

        if let index = event.rsvps.firstIndex(where: { $0.playerID == currentPlayer.id }) {
            // Already RSVP'd — update existing
            event.rsvps[index].status = status
        } else {
            // First RSVP — create new
            event.rsvps.append(RSVP(
                playerID: currentPlayer.id,
                playerName: currentPlayer.name,
                status: status
            ))
        }
        save()
        objectWillChange.send()
    }

    func currentUserRSVP(for event: GameEvent) -> RSVPStatus? {
        guard let player = currentCrew?.members.first else { return nil }
        return event.rsvp(for: player.id)
    }

    // MARK: - Private SwiftData helpers

    /// Fetches the first Crew from the SwiftData store.
    ///
    /// FetchDescriptor is like a typed SQL query.
    /// In Week 4 we keep it simple — one crew per device.
    private func fetchCrew() -> Crew? {
        let descriptor = FetchDescriptor<Crew>()
        return (try? modelContext.fetch(descriptor))?.first
    }

    private func save() {
        try? modelContext.save()
    }

    // MARK: - Helpers

    private func generateCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }
}
