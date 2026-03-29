import SwiftUI
import SwiftData

@main
struct BarraApp: App {
    var body: some Scene {
        WindowGroup {
            // WHY ModelContextBridge?
            //
            // .modelContainer() injects a ModelContext into the SwiftUI environment.
            // @StateObject must be initialized *before* body runs, but @Environment
            // values are only available *inside* body.
            //
            // ModelContextBridge solves this: it reads the context in its body,
            // then passes it to ContentView's init — where @StateObject can use it.
            ModelContextBridge()
        }
        .modelContainer(for: [Crew.self, Player.self, GameEvent.self])
    }
}

/// Thin bridge view that reads the SwiftData ModelContext from the environment
/// and passes it into ContentView where the ViewModel is created.
struct ModelContextBridge: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ContentView(modelContext: modelContext)
    }
}
