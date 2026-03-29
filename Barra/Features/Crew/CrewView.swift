import SwiftUI

/// The root of the Crew tab.
///
/// Acts as a "gate view" — looks at crewVM.currentCrew and decides
/// whether to show the empty state (no crew) or the crew detail.
struct CrewView: View {

    @ObservedObject var crewVM: CrewViewModel

    @State private var showCreate = false
    @State private var showJoin = false

    var body: some View {
        NavigationStack {
            ZStack {
                BarraTheme.background.ignoresSafeArea()

                if let crew = crewVM.currentCrew {
                    crewExistsView(crew: crew)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .opacity
                        ))
                } else {
                    emptyStateView
                        .transition(.opacity)
                }
            }
            .animation(.barraBounce, value: crewVM.currentCrew != nil)
            .navigationTitle("The Crew")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showCreate) {
            CreateCrewView(crewVM: crewVM)
        }
        .sheet(isPresented: $showJoin) {
            JoinCrewView(crewVM: crewVM)
        }
    }

    // MARK: - Crew exists

    @ViewBuilder
    private func crewExistsView(crew: Crew) -> some View {
        VStack(spacing: BarraTheme.paddingM) {
            NavigationLink(destination: CrewDetailView(crewVM: crewVM)) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(crew.name)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(BarraTheme.primary)
                        Text("\(crew.members.count) member\(crew.members.count == 1 ? "" : "s")  ·  \(crew.inviteCode)")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(BarraTheme.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(BarraTheme.secondary)
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(BarraTheme.paddingM)
                .background(BarraTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: BarraTheme.cornerRadius)
                        .stroke(BarraTheme.secondary.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(BarraCardPressStyle())
            .padding(.horizontal, BarraTheme.paddingM)
            .staggeredAppearance(index: 0)

            // Upcoming events preview
            if let crew = crewVM.currentCrew {
                let upcoming = crew.events.filter { $0.isUpcoming }.sorted { $0.date < $1.date }.prefix(2)
                if !upcoming.isEmpty {
                    VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
                        Text("UPCOMING")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(BarraTheme.secondary)
                            .tracking(1.5)
                            .padding(.horizontal, BarraTheme.paddingM)

                        ForEach(Array(upcoming.enumerated()), id: \.element.id) { idx, event in
                            HStack(spacing: 12) {
                                VStack(spacing: 2) {
                                    Text(event.date.formatted(.dateTime.month(.abbreviated)))
                                        .font(.system(size: 10, weight: .medium, design: .rounded))
                                        .foregroundStyle(BarraTheme.accent)
                                    Text(event.date.formatted(.dateTime.day()))
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(BarraTheme.primary)
                                }
                                .frame(width: 36)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.title)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(BarraTheme.primary)
                                    Text(event.date.formatted(.dateTime.hour().minute()))
                                        .font(.system(size: 13, design: .rounded))
                                        .foregroundStyle(BarraTheme.secondary)
                                }
                                Spacer()
                            }
                            .padding(BarraTheme.paddingM)
                            .background(BarraTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: BarraTheme.cornerRadius))
                            .padding(.horizontal, BarraTheme.paddingM)
                            .staggeredAppearance(index: idx + 1)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.top, BarraTheme.paddingM)
    }

    // MARK: - Empty state (with moon scene)

    private var emptyStateView: some View {
        VStack(spacing: BarraTheme.paddingL) {
            Spacer()

            // Animated moon illustration
            BarraMoonScene(moonSize: 80)
                .staggeredAppearance(index: 0)

            // Copy
            VStack(spacing: 8) {
                Text("No crew yet")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(BarraTheme.primary)
                Text("Create a crew or join one\nwith an invite code.")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(BarraTheme.secondary)
                    .multilineTextAlignment(.center)
            }
            .staggeredAppearance(index: 1)

            Spacer()

            // Actions
            VStack(spacing: BarraTheme.paddingS) {
                BarraButton(title: "Create a Crew", icon: "plus") {
                    showCreate = true
                }
                BarraButton(title: "Join with a Code", style: .secondary, icon: "link") {
                    showJoin = true
                }
            }
            .padding(.horizontal, BarraTheme.paddingM)
            .padding(.bottom, BarraTheme.paddingL)
            .staggeredAppearance(index: 2)
        }
    }
}

#Preview("Empty state") {
    CrewView(crewVM: {
        let container = try! ModelContainer(for: Crew.self, Player.self, GameEvent.self)
        return CrewViewModel(modelContext: container.mainContext)
    }())
}
