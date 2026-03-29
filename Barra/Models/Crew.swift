import Foundation

/// A friend group in Barra.
///
/// Kept as a pure data struct — no logic lives here.
/// All behavior (create, join, leave) belongs in CrewViewModel.
struct Crew: Identifiable, Codable {
    let id: UUID
    var name: String
    var inviteCode: String  // 6-character alphanumeric code, e.g. "XK92BQ"
    var members: [Player]

    init(id: UUID = UUID(), name: String, inviteCode: String, members: [Player] = []) {
        self.id = id
        self.name = name
        self.inviteCode = inviteCode
        self.members = members
    }
}
