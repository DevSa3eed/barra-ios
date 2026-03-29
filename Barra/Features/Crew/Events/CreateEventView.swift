import SwiftUI

/// Sheet — presented when the user taps "Schedule a Game Night".
struct CreateEventView: View {

    @ObservedObject var crewVM: CrewViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = "Game Night"
    @State private var date = defaultDate()
    @State private var location = ""
    @State private var notes = ""

    private var canSchedule: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BarraTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: BarraTheme.paddingL) {

                        // Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Schedule a game night")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(BarraTheme.primary)
                            Text("Lock in the date so the crew shows up.")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(BarraTheme.secondary)
                        }

                        // Fields
                        VStack(spacing: BarraTheme.paddingM) {

                            // Title
                            fieldSection(label: "Event name") {
                                BarraTextField(placeholder: "e.g. Friday Game Night", text: $title)
                            }

                            // Date & time
                            fieldSection(label: "Date & Time") {
                                DatePicker(
                                    "",
                                    selection: $date,
                                    in: Date.now...,        // can't schedule in the past
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .datePickerStyle(.graphical)
                                .tint(BarraTheme.accent)
                                .padding(BarraTheme.paddingM)
                                .background(BarraTheme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
                            }

                            // Location (optional)
                            fieldSection(label: "Location (optional)") {
                                BarraTextField(placeholder: "e.g. Mohamed's place", text: $location)
                            }

                            // Notes (optional)
                            fieldSection(label: "Notes (optional)") {
                                ZStack(alignment: .topLeading) {
                                    TextEditor(text: $notes)
                                        .font(.system(size: 16, design: .rounded))
                                        .frame(minHeight: 80)
                                        .scrollContentBackground(.hidden)
                                        .padding(12)

                                    if notes.isEmpty {
                                        Text("e.g. Bring snacks, starts at 9pm")
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundStyle(BarraTheme.secondary.opacity(0.5))
                                            .padding(16)
                                            .allowsHitTesting(false)
                                    }
                                }
                                .background(BarraTheme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                                        .stroke(BarraTheme.secondary.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }

                        Spacer(minLength: BarraTheme.paddingL)

                        BarraButton(title: "Schedule It") {
                            crewVM.scheduleEvent(
                                title: title.trimmingCharacters(in: .whitespaces),
                                date: date,
                                location: location.trimmingCharacters(in: .whitespaces),
                                notes: notes.trimmingCharacters(in: .whitespaces)
                            )
                            dismiss()
                        }
                        .disabled(!canSchedule)
                        .opacity(canSchedule ? 1.0 : 0.5)
                        .padding(.bottom, BarraTheme.paddingL)
                    }
                    .padding(BarraTheme.paddingL)
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(BarraTheme.accent)
                }
            }
        }
    }

    @ViewBuilder
    private func fieldSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)
                .tracking(1.5)
            content()
        }
    }

    /// Defaults to tomorrow at 8pm — a sensible game night time.
    private static func defaultDate() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        components.day! += 1
        components.hour = 20
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
}

#Preview {
    CreateEventView(crewVM: {
        let vm = CrewViewModel(modelContext: try! ModelContainer(for: Crew.self, Player.self, GameEvent.self).mainContext)
        return vm
    }())
}
