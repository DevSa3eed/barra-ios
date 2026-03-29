import SwiftUI

/// Sheet — presented when the user taps "Join a Crew".
struct JoinCrewView: View {

    @ObservedObject var crewVM: CrewViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var code = ""
    @State private var yourName = ""
    @State private var showError = false

    private var canJoin: Bool {
        code.count == 6 && !yourName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BarraTheme.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: BarraTheme.paddingL) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Enter invite code")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(BarraTheme.primary)
                        Text("Ask your crew for their 6-character code.")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(BarraTheme.secondary)
                    }

                    // Fields
                    VStack(spacing: BarraTheme.paddingM) {
                        // Code field — uppercase, 6 chars max
                        TextField("Invite code (e.g. XK92BQ)", text: $code)
                            .font(.system(size: 22, weight: .semibold, design: .monospaced))
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .multilineTextAlignment(.center)
                            .tracking(8)
                            .padding(BarraTheme.paddingM)
                            .background(BarraTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                                    .stroke(
                                        showError ? Color.red : BarraTheme.secondary.opacity(0.3),
                                        lineWidth: showError ? 1.5 : 1
                                    )
                            )
                            // Cap at 6 characters and always uppercase
                            .onChange(of: code) { _, newValue in
                                code = String(newValue.uppercased().prefix(6))
                                if showError { showError = false }
                            }

                        BarraTextField(placeholder: "Your name", text: $yourName)
                    }

                    // Error message
                    if showError {
                        Text("Invalid code. Ask your crew for the correct 6-character code.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(.red)
                    }

                    Spacer()

                    // Join button
                    BarraButton(title: "Join Crew") {
                        let success = crewVM.joinCrew(
                            code: code,
                            yourName: yourName.trimmingCharacters(in: .whitespaces)
                        )
                        if success {
                            dismiss()
                        } else {
                            showError = true
                        }
                    }
                    .disabled(!canJoin)
                    .opacity(canJoin ? 1.0 : 0.5)
                }
                .padding(BarraTheme.paddingL)
            }
            .navigationTitle("Join a Crew")
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

#Preview {
    JoinCrewView(crewVM: CrewViewModel())
}
