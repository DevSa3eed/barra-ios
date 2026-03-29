import SwiftUI
import SwiftData

struct ContentView: View {

    // @StateObject: ContentView owns the ViewModel for the app's lifetime.
    //
    // HOW TO INIT @StateObject WITH AN EXTERNAL VALUE:
    // You can't write `@StateObject private var crewVM = CrewViewModel(modelContext: x)`
    // when `x` comes from outside. Instead, use the underscore prefix to access
    // the property wrapper itself and call StateObject(wrappedValue:) directly.
    @StateObject private var crewVM: CrewViewModel

    init(modelContext: ModelContext) {
        _crewVM = StateObject(wrappedValue: CrewViewModel(modelContext: modelContext))
    }

    var body: some View {
        TabView {
            CrewView(crewVM: crewVM)
                .tabItem {
                    Label("The Crew", systemImage: "person.3.fill")
                }

            GamesView()
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
        }
        .tint(BarraTheme.accent)
    }
}
