import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                BarraTheme.background.ignoresSafeArea()

                VStack(spacing: BarraTheme.paddingL) {
                    Spacer()

                    // Animated moon illustration
                    BarraMoonScene(moonSize: 60, sceneWidth: 160, sceneHeight: 140)
                        .staggeredAppearance(index: 0)

                    VStack(spacing: 8) {
                        Text("No history yet")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(BarraTheme.primary)
                        Text("Your game night results\nwill appear here.")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(BarraTheme.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .staggeredAppearance(index: 1)

                    Spacer()
                    Spacer()
                }
                .padding(BarraTheme.paddingM)
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    HistoryView()
}
