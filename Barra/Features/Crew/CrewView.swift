import SwiftUI

/// The root of the Crew tab.
///
/// Acts as a "gate view" — looks at crewVM.currentCrew and decides
/// whether to show the empty state (no crew) or the crew detail.
///
/// WHY @ObservedObject here and @StateObject in ContentView?
///   ContentView CREATES the ViewModel — it owns it (@StateObject).
///   CrewView RECEIVES it — it just observes it (@ObservedObject).
///   If you used @StateObject here, a new ViewModel would be created
///   every time SwiftUI rebuilt CrewView, wiping the saved crew.
struct CrewView: View {

    @ObservedObject var crewVM: CrewViewModel

    // Local UI state — only controls whether sheets are visible
    @State private var showCreate = false
    @State private var showJoin = false

    var body: some View {
        NavigationStack {
            ZStack {
                BarraTheme.background.ignoresSafeArea()

                if let crew = crewVM.currentCrew {
                    // Crew exists → navigate to detail
                    crewExistsView(crew: crew)
                } else {
                    // No crew → show empty state with create/join
                    emptyStateView
                }
            }
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

    // MARK: - Subviews

    @ViewBuilder
    private func crewExistsView(crew: Crew) -> some View {
        VStack(spacing: BarraTheme.paddingM) {
            // Crew card — taps into CrewDetailView
            NavigationLink(destination: CrewDetailView(crewVM: crewVM)) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(crew.name)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(BarraTheme.primary)
                        Text("\(crew.members.count) member\(crew.members.count == 1 ? "" : "s")  •  \(crew.inviteCode)")
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
            .padding(.horizontal, BarraTheme.paddingM)

            Spacer()
        }
        .padding(.top, BarraTheme.paddingM)
    }

    private var emptyStateView: some View {
        VStack(spacing: BarraTheme.paddingL) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(BarraTheme.accent.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: "person.3.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(BarraTheme.accent)
            }

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

            Spacer()

            // Actions
            VStack(spacing: BarraTheme.paddingS) {
                BarraButton(title: "Create a Crew") {
                    showCreate = true
                }
                BarraButton(title: "Join with a Code", style: .secondary) {
                    showJoin = true
                }
            }
            .padding(.horizontal, BarraTheme.paddingM)
            .padding(.bottom, BarraTheme.paddingL)
        }
    }
}

#Preview("Empty state") {
    CrewView(crewVM: CrewViewModel())
}

#Preview("Has crew") {
    let vm = CrewViewModel()
    vm.createCrew(name: "The Wolves", yourName: "Mohamed")
    return CrewView(crewVM: vm)
}
