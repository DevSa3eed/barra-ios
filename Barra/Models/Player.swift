import Foundation

/// A single person in a crew.
///
/// - `Identifiable`  → ForEach can iterate an array of Players without specifying a key path
/// - `Codable`       → can be saved to / loaded from UserDefaults via JSON
/// - `Equatable`     → lets you use .contains() to check membership
struct Player: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
