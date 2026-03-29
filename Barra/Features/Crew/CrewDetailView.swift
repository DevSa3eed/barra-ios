import SwiftUI

/// Shows crew details: name, invite code, and member list.
/// Pushed onto the NavigationStack from CrewView.
struct CrewDetailView: View {

    @ObservedObject var crewVM: CrewViewModel
    @State private var codeCopied = false
    @State private var showLeaveConfirm = false

    var body: some View {
        // If there's no crew, this view shouldn't be visible — but guard anyway
        guard let crew = crewVM.currentCrew else { return AnyView(EmptyView()) }

        return AnyView(
            ZStack {
                BarraTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: BarraTheme.paddingL) {

                        // Invite code card
                        inviteCodeCard(crew: crew)

                        // Members list
                        membersSection(crew: crew)

                        Spacer(minLength: BarraTheme.paddingL)

                        // Leave crew
                        BarraButton(title: "Leave Crew", style: .secondary) {
                            showLeaveConfirm = true
                        }
                    }
                    .padding(BarraTheme.paddingM)
                }
            }
            .navigationTitle(crew.name)
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog(
                "Leave \(crew.name)?",
                isPresented: $showLeaveConfirm,
                titleVisibility: .visible
            ) {
                Button("Leave Crew", role: .destructive) {
                    crewVM.leaveCrew()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You'll need the invite code to rejoin.")
            }
        )
    }

    // MARK: - Subviews

    @ViewBuilder
    private func inviteCodeCard(crew: Crew) -> some View {
        VStack(spacing: BarraTheme.paddingS) {
            Text("Invite Code")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)
                .textCase(.uppercase)
                .tracking(1.5)

            // The code itself — tap to copy
            Button {
                UIPasteboard.general.string = crew.inviteCode
                withAnimation(.spring(response: 0.3)) {
                    codeCopied = true
                }
                // Reset after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { codeCopied = false }
                }
            } label: {
                Text(crew.inviteCode)
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundStyle(BarraTheme.accent)
                    .tracking(10)
            }

            // Copy feedback
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

    @ViewBuilder
    private func membersSection(crew: Crew) -> some View {
        VStack(alignment: .leading, spacing: BarraTheme.paddingS) {
            Text("\(crew.members.count) Member\(crew.members.count == 1 ? "" : "s")")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(BarraTheme.secondary)
                .textCase(.uppercase)
                .tracking(1.5)

            VStack(spacing: 0) {
                ForEach(crew.members) { player in
                    HStack {
                        // Avatar circle
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
                        Divider()
                            .padding(.leading, 60)
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

#Preview {
    let vm = CrewViewModel()
    vm.createCrew(name: "The Wolves", yourName: "Mohamed")
    return NavigationStack {
        CrewDetailView(crewVM: vm)
    }
}
