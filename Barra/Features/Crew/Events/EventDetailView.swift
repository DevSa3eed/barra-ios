import SwiftUI

/// Detail view for a single scheduled event — shows info and lets the user RSVP.
struct EventDetailView: View {

    @ObservedObject var crewVM: CrewViewModel
    let event: GameEvent

    @State private var showDeleteConfirm = false

    private var currentRSVP: RSVPStatus? {
        crewVM.currentUserRSVP(for: event)
    }

    var body: some View {
        ZStack {
            BarraTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: BarraTheme.paddingL) {

                    // Event header card
                    eventHeaderCard

                    // RSVP section
                    rsvpSection

                    // Attendees
                    if !event.rsvps.isEmpty {
                        attendeesSection
                    }
                }
                .padding(BarraTheme.paddingM)
            }
        }
        .navigationTitle(event.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .confirmationDialog("Delete \"\(event.title)\"?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete Event", role: .destructive) {
                crewVM.deleteEvent(event)
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Event header

    private var eventHeaderCard: some View {
        VStack(alignment: .leading, spacing: BarraTheme.paddingM) {

            // Date & time
            HStack(spacing: 12) {
                infoRow(
                    icon: "calendar",
                    text: event.date.formatted(date: .long, time: .omitted)
                )
            }
            infoRow(
                icon: "clock",
                text: event.date.formatted(date: .omitted, time: .shortened)
            )

            if !event.location.isEmpty {
                infoRow(icon: "mappin.circle.fill", text: event.location)
            }

            if !event.notes.isEmpty {
                Divider()
                Text(event.notes)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(BarraTheme.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(BarraTheme.paddingM)
        .background(BarraTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                .stroke(BarraTheme.secondary.opacity(0.2), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(BarraTheme.accent)
                .frame(width: 22)
            Text(text)
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(BarraTheme.primary)
        }
    }

    // MARK: - RSVP

    private var rsvpSection: some View {
        VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
            sectionLabel("Are you going?")

            HStack(spacing: BarraTheme.paddingS) {
                rsvpButton(.going)
                rsvpButton(.maybe)
                rsvpButton(.notGoing)
            }
        }
    }

    @ViewBuilder
    private func rsvpButton(_ status: RSVPStatus) -> some View {
        let isSelected = currentRSVP == status

        Button {
            withAnimation(.spring(response: 0.3)) {
                crewVM.rsvp(to: event, status: status)
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: status.icon)
                    .font(.system(size: 20))
                Text(status.label)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(isSelected ? .white : BarraTheme.primary)
            .background(isSelected ? rsvpColor(status) : BarraTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                    .stroke(
                        isSelected ? rsvpColor(status) : BarraTheme.secondary.opacity(0.3),
                        lineWidth: isSelected ? 0 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }

    private func rsvpColor(_ status: RSVPStatus) -> Color {
        switch status {
        case .going:    return Color(red: 0.18, green: 0.65, blue: 0.40)
        case .maybe:    return BarraTheme.accent
        case .notGoing: return Color(red: 0.75, green: 0.25, blue: 0.25)
        }
    }

    // MARK: - Attendees

    private var attendeesSection: some View {
        VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
            sectionLabel("Who's coming")

            // Summary counts
            HStack(spacing: BarraTheme.paddingM) {
                attendeeCount(event.goingCount, label: "Going", color: Color(red: 0.18, green: 0.65, blue: 0.40))
                attendeeCount(event.maybeCount, label: "Maybe", color: BarraTheme.accent)
            }
            .padding(.bottom, 4)

            // Individual RSVPs
            VStack(spacing: 0) {
                ForEach(event.rsvps) { rsvp in
                    HStack {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(rsvpColor(rsvp.status).opacity(0.15))
                                .frame(width: 36, height: 36)
                            Text(String(rsvp.playerName.prefix(1)).uppercased())
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(rsvpColor(rsvp.status))
                        }

                        Text(rsvp.playerName)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(BarraTheme.primary)

                        Spacer()

                        Label(rsvp.status.label, systemImage: rsvp.status.icon)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(rsvpColor(rsvp.status))
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, BarraTheme.paddingM)

                    if rsvp.id != event.rsvps.last?.id {
                        Divider().padding(.leading, 52)
                    }
                }
            }
            .background(BarraTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                    .stroke(BarraTheme.secondary.opacity(0.2), lineWidth: 1)
            )
        }
    }

    @ViewBuilder
    private func attendeeCount(_ count: Int, label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Text("\(count)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(BarraTheme.secondary)
            .tracking(1.5)
    }
}
