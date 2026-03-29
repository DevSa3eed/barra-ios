import SwiftUI

/// Shows crew details: name, invite code, members, and upcoming events.
/// Pushed onto the NavigationStack from CrewView.
struct CrewDetailView: View {

    @ObservedObject var crewVM: CrewViewModel
    @State private var codeCopied = false
    @State private var showLeaveConfirm = false
    @State private var showScheduleEvent = false

    var body: some View {
        guard let crew = crewVM.currentCrew else { return AnyView(EmptyView()) }

        let upcomingEvents = crew.events
            .filter { $0.isUpcoming }
            .sorted { $0.date < $1.date }

        let pastEvents = crew.events
            .filter { !$0.isUpcoming }
            .sorted { $0.date > $1.date }

        return AnyView(
            ZStack {
                BarraTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: BarraTheme.paddingL) {

                        // Invite code card
                        inviteCodeCard(crew: crew)

                        // Upcoming events
                        eventsSection(
                            title: "Upcoming",
                            events: upcomingEvents,
                            crew: crew,
                            emptyMessage: "No events yet — schedule a game night!"
                        )

                        // Past events (collapsed if many)
                        if !pastEvents.isEmpty {
                            eventsSection(
                                title: "Past",
                                events: pastEvents,
                                crew: crew,
                                emptyMessage: nil
                            )
                        }

                        // Members list
                        membersSection(crew: crew)

                        Spacer(minLength: BarraTheme.paddingL)

                        BarraButton(title: "Leave Crew", style: .secondary) {
                            showLeaveConfirm = true
                        }
                    }
                    .padding(BarraTheme.paddingM)
                }
            }
            .navigationTitle(crew.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showScheduleEvent = true
                    } label: {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundStyle(BarraTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showScheduleEvent) {
                CreateEventView(crewVM: crewVM)
            }
            .confirmationDialog(
                "Leave \(crew.name)?",
                isPresented: $showLeaveConfirm,
                titleVisibility: .visible
            ) {
                Button("Leave Crew", role: .destructive) { crewVM.leaveCrew() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You'll need the invite code to rejoin.")
            }
        )
    }

    // MARK: - Invite Code Card

    @ViewBuilder
    private func inviteCodeCard(crew: Crew) -> some View {
        VStack(spacing: BarraTheme.paddingS) {
            Text("Invite Code")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)
                .textCase(.uppercase)
                .tracking(1.5)

            Button {
                UIPasteboard.general.string = crew.inviteCode
                withAnimation(.spring(response: 0.3)) { codeCopied = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { codeCopied = false }
                }
            } label: {
                Text(crew.inviteCode)
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundStyle(BarraTheme.accent)
                    .tracking(10)
            }

            Label(
                codeCopied ? "Copied!" : "Tap to copy",
                systemImage: codeCopied ? "checkmark.circle.fill" : "doc.on.doc"
            )
            .font(.system(size: 13, design: .rounded))
            .foregroundStyle(codeCopied ? BarraTheme.accent : BarraTheme.secondary)
            .animation(.easeInOut, value: codeCopied)
        }
        .frame(maxWidth: .infinity)
        .padding(BarraTheme.paddingL)
        .background(BarraTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                .stroke(BarraTheme.secondary.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Events Section

    @ViewBuilder
    private func eventsSection(title: String, events: [GameEvent], crew: Crew, emptyMessage: String?) -> some View {
        VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
            HStack {
                sectionLabel(title)
                Spacer()
                if title == "Upcoming" {
                    Button {
                        showScheduleEvent = true
                    } label: {
                        Label("Schedule", systemImage: "plus")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(BarraTheme.accent)
                    }
                }
            }

            if events.isEmpty, let message = emptyMessage {
                // Empty state
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(BarraTheme.secondary.opacity(0.5))
                    Text(message)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(BarraTheme.secondary)
                }
                .padding(BarraTheme.paddingM)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BarraTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
            } else {
                VStack(spacing: 0) {
                    ForEach(events) { event in
                        NavigationLink(destination: EventDetailView(crewVM: crewVM, event: event)) {
                            eventRow(event: event)
                        }
                        .buttonStyle(.plain)

                        if event.id != events.last?.id {
                            Divider().padding(.leading, BarraTheme.paddingM)
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
    }

    @ViewBuilder
    private func eventRow(event: GameEvent) -> some View {
        HStack(spacing: BarraTheme.paddingM) {
            // Date badge
            VStack(spacing: 2) {
                Text(event.date.formatted(.dateTime.month(.abbreviated)))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(BarraTheme.accent)
                Text(event.date.formatted(.dateTime.day()))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(BarraTheme.primary)
            }
            .frame(width: 40)

            VStack(alignment: .leading, spacing: 3) {
                Text(event.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(BarraTheme.primary)

                HStack(spacing: 10) {
                    Text(event.date.formatted(.dateTime.hour().minute()))
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(BarraTheme.secondary)
                    if !event.location.isEmpty {
                        Text("·")
                            .foregroundStyle(BarraTheme.secondary)
                        Text(event.location)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(BarraTheme.secondary)
                            .lineLimit(1)
                    }
                }

                // RSVP summary
                if event.goingCount > 0 || event.maybeCount > 0 {
                    HStack(spacing: 8) {
                        if event.goingCount > 0 {
                            Label("\(event.goingCount) going", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(Color(red: 0.18, green: 0.65, blue: 0.40))
                        }
                        if event.maybeCount > 0 {
                            Label("\(event.maybeCount) maybe", systemImage: "questionmark.circle.fill")
                                .foregroundStyle(BarraTheme.accent)
                        }
                    }
                    .font(.system(size: 12, design: .rounded))
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(BarraTheme.secondary)
        }
        .padding(BarraTheme.paddingM)
    }

    // MARK: - Members Section

    @ViewBuilder
    private func membersSection(crew: Crew) -> some View {
        VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
            sectionLabel("\(crew.members.count) Member\(crew.members.count == 1 ? "" : "s")")

            VStack(spacing: 0) {
                ForEach(crew.members) { player in
                    HStack {
                        ZStack {
                            Circle()
                                .fill(BarraTheme.accent.opacity(0.15))
                                .frame(width: 40, height: 40)
                            Text(String(player.name.prefix(1)).uppercased())
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(BarraTheme.accent)
                        }
                        Text(player.name)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundStyle(BarraTheme.primary)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, BarraTheme.paddingM)

                    if player.id != crew.members.last?.id {
                        Divider().padding(.leading, 60)
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

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(BarraTheme.secondary)
            .tracking(1.5)
    }
}
