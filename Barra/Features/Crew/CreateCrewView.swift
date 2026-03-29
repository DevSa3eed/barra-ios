import SwiftUI
import SwiftData

/// Sheet — presented when the user taps "Create a Crew".
struct CreateCrewView: View {

    // Received from CrewView — does NOT own it
    @ObservedObject var crewVM: CrewViewModel

    // Sheet dismissal — no delegate needed, the sheet closes itself
    @Environment(\.dismiss) private var dismiss

    // Local UI state only — not business data
    @State private var crewName = ""
    @State private var yourName = ""

    private var canCreate: Bool {
        !crewName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !yourName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BarraTheme.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: BarraTheme.paddingL) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Name your crew")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(BarraTheme.primary)
                        Text("You can always change it later.")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(BarraTheme.secondary)
                    }

                    // Fields
                    VStack(spacing: BarraTheme.paddingM) {
                        BarraTextField(placeholder: "Crew name (e.g. The Wolves)", text: $crewName)
                        BarraTextField(placeholder: "Your name", text: $yourName)
                    }

                    Spacer()

                    // Create button
                    BarraButton(title: "Create Crew", icon: "sparkles") {
                        crewVM.createCrew(
                            name: crewName.trimmingCharacters(in: .whitespaces),
                            yourName: yourName.trimmingCharacters(in: .whitespaces)
                        )
                        HapticManager.success()
                        dismiss()
                    }
                    .disabled(!canCreate)
                    .opacity(canCreate ? 1.0 : 0.5)
                }
                .padding(BarraTheme.paddingL)
            }
            .navigationTitle("New Crew")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(BarraTheme.accent)
                }
            }
        }
    }
}

/// A reusable text field styled for Barra.
/// Kept here for now — can be moved to Components/ when used elsewhere.
struct BarraTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 16, design: .rounded))
            .padding(BarraTheme.paddingM)
            .background(BarraTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                    .stroke(BarraTheme.secondary.opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview {
    CreateCrewView(crewVM: {
        let container = try! ModelContainer(for: Crew.self, Player.self, GameEvent.self)
        return CrewViewModel(modelContext: container.mainContext)
    }())
}
