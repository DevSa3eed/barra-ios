import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CrewView()
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
