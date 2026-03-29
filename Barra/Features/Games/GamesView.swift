import SwiftUI

struct GamesView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                BarraTheme.background.ignoresSafeArea()

                VStack(spacing: BarraTheme.paddingL) {
                    Spacer()
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(BarraTheme.accent)
                    BarraTheme.title("Games")
                    BarraTheme.body("Password, Mafia, and more coming soon.")
                    Spacer()
                }
                .padding(BarraTheme.paddingM)
            }
            .navigationTitle("Games")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    GamesView()
}
