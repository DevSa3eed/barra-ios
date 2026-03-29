import SwiftUI

struct ContentView: View {

    // @StateObject = ContentView OWNS this ViewModel.
    // It is created exactly once and lives for the app's lifetime.
    // Every sub-view that needs it receives it with @ObservedObject.
    @StateObject private var crewVM = CrewViewModel()

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

#Preview {
    ContentView()
}
