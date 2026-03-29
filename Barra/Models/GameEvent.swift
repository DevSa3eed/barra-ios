import Foundation
import SwiftData

// MARK: - RSVP Status

/// Whether someone is attending the event.
/// `Codable` so it can be stored inside the `rsvps` array on GameEvent.
enum RSVPStatus: String, Codable {
    case going
    case maybe
    case notGoing

    var label: String {
        switch self {
        case .going:    return "Going"
        case .maybe:    return "Maybe"
        case .notGoing: return "Not Going"
        }
    }

    var icon: String {
        switch self {
        case .going:    return "checkmark.circle.fill"
        case .maybe:    return "questionmark.circle.fill"
        case .notGoing: return "xmark.circle.fill"
        }
    }
}

// MARK: - RSVP

/// A single person's RSVP for an event.
///
/// This is a plain Codable struct — NOT a @Model — because it's stored
/// as a JSON-encoded array inside GameEvent. Simple nested data doesn't
/// need its own SwiftData table.
struct RSVP: Codable, Identifiable {
    let id: UUID
    let playerID: UUID
    let playerName: String
    var status: RSVPStatus

    init(playerID: UUID, playerName: String, status: RSVPStatus) {
        self.id = UUID()
        self.playerID = playerID
        self.playerName = playerName
        self.status = status
    }
}

// MARK: - GameEvent

/// A scheduled game night (or any crew hangout).
///
/// @Model: persisted to the SwiftData store.
/// `rsvps` is a [RSVP] — SwiftData stores Codable arrays as JSON automatically.
/// `crew` is a back-reference; Crew.events is the owning side of the relationship.
@Model
final class GameEvent {
    var id: UUID
    var title: String
    var date: Date
    var location: String
    var notes: String
    var rsvps: [RSVP]   // Codable array — stored as JSON, no extra @Model needed

    // Back-reference — SwiftData manages this via @Relationship on Crew.events
    var crew: Crew?

    init(title: String, date: Date, location: String = "", notes: String = "") {
        self.id = UUID()
        self.title = title
        self.date = date
        self.location = location
        self.notes = notes
        self.rsvps = []
    }

    // MARK: - Computed helpers

    var isUpcoming: Bool { date >= Date.now }

    var goingCount: Int  { rsvps.filter { $0.status == .going }.count }
    var maybeCount: Int  { rsvps.filter { $0.status == .maybe }.count }

    func rsvp(for playerID: UUID) -> RSVPStatus? {
        rsvps.first(where: { $0.playerID == playerID })?.status
    }
}
