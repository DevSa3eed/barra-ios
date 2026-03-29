import Foundation
import SwiftData

/// A friend group in Barra.
///
/// WEEK 4 CHANGE: Converted from a struct to a SwiftData @Model class.
///
/// @Relationship rules:
///   - deleteRule: .cascade  → when the Crew is deleted, all its members and events are too
///   - inverse: \Player.crew → SwiftData keeps the back-reference in sync automatically
///     (setting crew.members = [...] also sets each player.crew = crew)
@Model
final class Crew {
    var id: UUID
    var name: String
    var inviteCode: String

    @Relationship(deleteRule: .cascade, inverse: \Player.crew)
    var members: [Player]

    @Relationship(deleteRule: .cascade, inverse: \GameEvent.crew)
    var events: [GameEvent]

    init(name: String, inviteCode: String) {
        self.id = UUID()
        self.name = name
        self.inviteCode = inviteCode
        self.members = []
        self.events = []
    }
}
