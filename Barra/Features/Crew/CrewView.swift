import SwiftUI

struct CrewView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                BarraTheme.background.ignoresSafeArea()

                VStack(spacing: BarraTheme.paddingL) {
                    Spacer()
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(BarraTheme.accent)
                    BarraTheme.title("The Crew")
                    BarraTheme.body("Create or join a group to get started.")
                    Spacer()
                }
                .padding(BarraTheme.paddingM)
            }
            .navigationTitle("The Crew")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    CrewView()
}
