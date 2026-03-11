import SwiftUI

struct TransfersView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var progressStore: PlayerProgressStore
    @ObservedObject var careerStore: CareerStore
    var onDismiss: (() -> Void)?
    @State private var showProfile = false
    @State private var showNotificationSettings = false
    @StateObject private var userInfoStore = UserInfoStore()

    private let cornerRadius: CGFloat = 12

    private var mainLevel: Int { progressStore.mainLevel }
    private var currentSlotIndex: Int? { careerStore.currentTransferSlotIndex(mainLevel: mainLevel, winsTowardNextTransfer: progressStore.winsTowardNextTransfer) }
    private var availableTeams: [Team] { careerStore.availableTeamsForCurrentSlot(mainLevel: mainLevel, winsTowardNextTransfer: progressStore.winsTowardNextTransfer) }

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                MainBackgroundView()
                NavigationLink(
                    destination: ProfileView(onDismiss: { showProfile = false }, progressStore: progressStore, careerStore: careerStore),
                    isActive: $showProfile
                ) {
                    EmptyView()
                }
                .hidden()
                .frame(width: 0, height: 0)
                .zIndex(-1)

                NavigationLink(
                    destination: NotificationSettingsView(onDismiss: { showNotificationSettings = false }),
                    isActive: $showNotificationSettings
                ) {
                    EmptyView()
                }
                .hidden()
                .frame(width: 0, height: 0)
                .zIndex(-1)

                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: 100)
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Transfers")
                                .font(.title).bold()
                                .foregroundStyle(.white)
                            Text("You can choose a team for your \ncharacter")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                            HStack {
                                playerCardSection
                                VStack {
                                    winsProgressSection
                                    statsCardSection
                                }
                            }
                            VStack(spacing: 24) {
                                
                                careerPathSection
                                if careerStore.hasReachedGoal {
                                    goalReachedMessage
                                } else {
                                    nextLevelClubsSection
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 40)
                        }
                        .padding(.top, 16)
                        Rectangle()
                            .frame(height: 200)
                            .foregroundStyle(Color.clear)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(1)
            }
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showNotificationSettings = true
                    } label: {
                        Image("notification")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showProfile = true
                    } label: {
                        Image("profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var winsProgressSection: some View {
        let filled = progressStore.winsTowardNextTransfer
        let total = PlayerProgressStore.winsProgressBarMax
        return HStack(spacing: 2) {
            ForEach(0..<total, id: \.self) { index in
                ParallelogramSegment(filled: index < filled)
            }
            .padding(.leading, 5)
            HStack(spacing: 0) {
                Text("\(filled)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
                Text("/\(total)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(.leading, 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .frame(height: 60)
        .background(Color(.darkGreen))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .padding(.trailing, 20)
    }
    
    private var playerCardSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(userInfoStore.userInfo.name.isEmpty ? "Player" : userInfoStore.userInfo.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    VStack(spacing: 4) {
                        Text("\(progressStore.totalLevelPercentage)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(userInfoStore.userInfo.position.isEmpty ? "—" : userInfoStore.userInfo.position)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                Image("mainP")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 200)
            }
            .padding()
            .frame(height: 300)
            .background(Color(.darkGreen))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .padding(.leading, 20)
        }
    }

    private var statsCardSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(spacing: 5) {
                statRow(name: StatKind.speed.rawValue, value: progressStore.speed)
                statRow(name: StatKind.passing.rawValue, value: progressStore.passing)
                statRow(name: StatKind.shooting.rawValue, value: progressStore.shooting)
                statRow(name: StatKind.defense.rawValue, value: progressStore.defense)
                statRow(name: StatKind.stamina.rawValue, value: progressStore.stamina)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .frame(height: 230)
        .background(Color(.darkGreen))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .padding(.trailing, 20)
    }
    
    private func statRow(name: String, value: Int) -> some View {
        VStack {
            HStack {
                Text(name)
                    .font(.body)
                    .foregroundColor(.white)
                Spacer()
                Text("\(value)/\(PlayerProgress.maxStat)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            ProgressView(value: Double(value), total: Double(PlayerProgress.maxStat))
                .frame(width: 120)
                .tint(.orange)
        }
    }

    private var careerPathSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ForEach(0..<4, id: \.self) { index in
                    if let team = careerStore.transferSlots[index] {
                        clubFrame(team: team)
                    } else {
                        emptyCareerFrame()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func emptyCareerFrame() -> some View {
        VStack(spacing: 6) {
            Image("emptyTeam")
                .resizable()
                .scaledToFit()
                .frame(height: 44)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(Color(.darkGreen))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private func clubFrame(team: Team) -> some View {
        VStack(spacing: 0) {
            Image(team.logoName)
                .resizable()
                .scaledToFit()
                .frame(height: 44)
            Text(team.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
            Text(team.starText)
                .font(.caption2)
                .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(Color(.darkGreen))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var goalReachedMessage: some View {
        Text("You have reached your desired goal, no more club changes are allowed")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var nextLevelSlotIndex: Int {
        if let current = currentSlotIndex { return current }
        return careerStore.transferSlots.firstIndex(where: { $0 == nil }) ?? 0
    }

    private var nextLevelClubsSection: some View {
        let slotIndex = nextLevelSlotIndex
        let slotLevel = slotIndex + 2
        let canTransfer = currentSlotIndex == slotIndex
        let teams = careerStore.teamsForSlotDisplay(slotIndex: slotIndex)

        return VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                Color(.darkGreen)
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        ForEach(teams) { team in
                            Button {
                                if canTransfer {
                                    careerStore.selectTeam(team, forSlotIndex: slotIndex)
                                    progressStore.resetWinsTowardNextTransfer()
                                }
                            } label: {
                                clubCard(team: team)
                            }
                            .buttonStyle(.plain)
                            .disabled(!canTransfer)
                        }
                    }
                    if canTransfer {
                        Button {
                            careerStore.selectRandomTeamForCurrentSlot(mainLevel: mainLevel, winsTowardNextTransfer: progressStore.winsTowardNextTransfer)
                            progressStore.resetWinsTowardNextTransfer()
                        } label: {
                            HStack {
                                Image(systemName: "shuffle")
                                Text("Random team")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                if !canTransfer {
                    Color.black.opacity(0.6)
                        .allowsHitTesting(true)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .allowsHitTesting(canTransfer)
        }
    }

    private func clubCard(team: Team) -> some View {
        VStack(spacing: 0) {
            Image(team.logoName)
                .resizable()
                .scaledToFit()
                .frame(height: 48)
            Text(team.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
            Text(team.starText)
                .font(.caption)
                .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .padding()
        .background(Color(.darkGreen))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

private struct ParallelogramShape: Shape {
    var skew: CGFloat = 4

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: skew, y: 0))
        path.addLine(to: CGPoint(x: w + skew, y: 0))
        path.addLine(to: CGPoint(x: w - skew, y: h))
        path.addLine(to: CGPoint(x: -skew, y: h))
        path.closeSubpath()
        return path
    }
}

private struct ParallelogramSegment: View {
    let filled: Bool

    var body: some View {
        Rectangle()
            .fill(filled ? Color.orange : Color(red: 0.06, green: 0.15, blue: 0.1))
            .clipShape(ParallelogramShape(skew: 3))
            .frame(height: 8)
            .frame(width: 15)
    }
}
