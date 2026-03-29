import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                BarraTheme.background.ignoresSafeArea()

                VStack(spacing: BarraTheme.paddingL) {
                    Spacer()
                    Image(systemName: "clock.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(BarraTheme.accent)
                    BarraTheme.title("History")
                    BarraTheme.body("Your past game nights will appear here.")
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
