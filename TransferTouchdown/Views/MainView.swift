import SwiftUI

struct MainView: View {
    var onSelectTab: (MainTab) -> Void
    @ObservedObject var progressStore: PlayerProgressStore
    @ObservedObject var careerStore: CareerStore
    @State private var showProfile = false
    @State private var showNotificationSettings = false
    @StateObject private var userInfoStore = UserInfoStore()

    private let cornerRadius: CGFloat = 12

    private static let dailyPredictions: [String] = [
        "Today your athlete performs sharper — expect better training results.",
        "A strong team may notice you soon — stay prepared.",
        "Your player's motivation rises — perfect moment for harder drills.",
        "A new transfer opportunity could appear unexpectedly today.",
        "Training focus increases — skill growth will be faster than usual."
    ]

    private var dailyPredictionText: String {
        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let index = dayIndex % Self.dailyPredictions.count
        return Self.dailyPredictions[index]
    }

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
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                playerCardSection
                                VStack {
                                    winsProgressSection
                                    statsCardSection
                                }
                            }
                            HStack {
                                teamSection
                                dailyPredictionSection
                            }
                            shortcutButtonsSection
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

    private var teamSection: some View {
        VStack(alignment: .center) {
            VStack {
                Image(careerStore.currentTeam.logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                Text(careerStore.currentTeam.starText)
                    .font(.subheadline)
                    .foregroundColor(.orange)
                Text(careerStore.currentTeam.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.bottom, 5)

            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 150)
        .background(Color(.darkGreen))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .padding(.leading, 20)
    }

    private var dailyPredictionSection: some View {
        VStack(alignment: .center) {
            Text("Daily prediction")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)

            Text(dailyPredictionText)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 150)
        .background(Color(.darkGreen))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        
        .padding(.trailing, 20)
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

    private var shortcutButtonsSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            VStack(spacing: 10) {
                Button {
                    onSelectTab(.training)
                } label: {
                    HStack {
                        Spacer()
                        Text(MainTab.training.title + " Now")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(.orange))
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                }
                .buttonStyle(.plain)
                
                HStack{
                    Button {
                        onSelectTab(.transfers)
                    } label: {
                        HStack {
                            Spacer()
                            Text(MainTab.transfers.title)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(.darkGreen))
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    }
                    .buttonStyle(.plain)

                    Button {
                        onSelectTab(.progress)
                    } label: {
                        HStack {
                            Spacer()
                            Text(MainTab.progress.title)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(.darkGreen))
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
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
