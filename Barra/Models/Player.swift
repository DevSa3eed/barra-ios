import Foundation
import SwiftData

/// A single person in a crew.
///
/// WEEK 4 CHANGE: This is now a SwiftData @Model class instead of a struct.
///
/// KEY DIFFERENCE from a struct:
///   - Classes are reference types — SwiftData tracks changes to them automatically.
///   - @Model adds persistence magic: save, fetch, delete via ModelContext.
///   - The `crew` property is a SwiftData relationship (back-reference to the owning crew).
@Model
final class Player {
    var id: UUID
    var name: String

    // Back-reference to the crew this player belongs to.
    // SwiftData manages this automatically when you use @Relationship on Crew.members.
    var crew: Crew?

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
