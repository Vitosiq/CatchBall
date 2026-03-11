import SwiftUI

struct AppProgressView: View {
    @ObservedObject var progressStore: PlayerProgressStore
    @ObservedObject var careerStore: CareerStore
    private let cornerRadius: CGFloat = 12
    private let gameFrameSize: CGFloat = 44
    @State private var showProfile = false
    @State private var showNotificationSettings = false
    
    
    var body: some View {
        NavigationView {
            ZStack {
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
                        .frame(height: 50)
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Progress")
                                .font(.title).bold()
                                .foregroundStyle(.white)
                            Text("Progress your character in different \ncategories")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                            todayGamesSection
                            progressFramesSection
                        }
                        .padding(.top, 16)
                        Rectangle()
                            .frame(height: 200)
                            .foregroundStyle(Color.clear)
                    }
                }
                .zIndex(1)
                .allowsHitTesting(true)
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
    
    private var todayGamesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Day streak")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            HStack(spacing: 1) {
                ForEach(0..<7, id: \.self) { index in
                    gameResultFrame(status: progressStore.last7DaysStatus[index])
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func gameResultFrame(status: DayStatus) -> some View {
        let imageName: String = {
            switch status {
            case .won: return "won"
            case .lost: return "lost"
            case .notPlayed: return "notPlayed"
            }
        }()
        return Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
    }
    
    
    private var progressFramesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stats")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)

            let columns = [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]

            LazyVGrid(columns: columns, spacing: 12) {
                progressFrame(label: StatKind.speed.rawValue, value: progressStore.speed, max: 100, imageName: "speed")
                progressFrame(label: StatKind.passing.rawValue, value: progressStore.passing, max: 100, imageName: "passing")
                progressFrame(label: StatKind.shooting.rawValue, value: progressStore.shooting, max: 100, imageName: "shooting")
                progressFrame(label: StatKind.defense.rawValue, value: progressStore.defense, max: 100, imageName: "defense")
                progressFrame(label: StatKind.stamina.rawValue, value: progressStore.stamina, max: 100, imageName: "stamina")
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func progressFrame(label: String, value: Int, max: Int, imageName: String,) -> some View {
        VStack(spacing: 8) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                Spacer()
                Text("\(value)/\(max)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.tertiarySystemBackground))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.orange)
                        .frame(
                            width: Swift.max(
                                0,
                                geo.size.width * CGFloat(value) / CGFloat(max)
                            )
                        )
                }
            }
            .frame(height: 8)
            
            Spacer()
        }
        .padding()
        .background(Color(.darkGreen))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .aspectRatio(1, contentMode: .fit)
    }
    
}
