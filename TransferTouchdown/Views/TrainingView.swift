import SwiftUI

struct TrainingView: View {
    @ObservedObject var progressStore: PlayerProgressStore
    @ObservedObject var careerStore: CareerStore
    @Binding var hideTabBar: Bool
    var onSwitchToTransfers: (() -> Void)?
    var onSwitchToHome: (() -> Void)?
    @StateObject private var userInfoStore = UserInfoStore()
    @State private var selectedCardIndex = 0
    @State private var showMiniGame = false
    @State private var showProfile = false
    @State private var showNotificationSettings = false
    private let stats = StatKind.allCases
    private let cornerRadius: CGFloat = 12

    private var selectedStat: StatKind { stats[selectedCardIndex] }

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

                NavigationLink(
                    destination: TrainingMiniGameView(
                        progressStore: progressStore,
                        stat: selectedStat,
                        onDismiss: { showMiniGame = false },
                        onSwitchToTransfers: { onSwitchToTransfers?() },
                        onGoHome: {
                            onSwitchToHome?()
                            showMiniGame = false
                        },
                        careerStore: careerStore
                    ),
                    isActive: $showMiniGame
                ) { EmptyView() }
                .hidden()
                .frame(width: 0, height: 0)
                .zIndex(-1)

                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: 100)
                    ScrollView {
                        VStack(spacing: 20) {
                            cardCarouselSection
                                .padding(.top, 60)
                        }
                        .padding(.horizontal, 20)
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
            .navigationBarTitleDisplayMode(.inline)
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
            .onChange(of: showMiniGame) { newValue in
                hideTabBar = newValue
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var cardCarouselSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCardIndex = (selectedCardIndex - 1 + stats.count) % stats.count
                    }
                } label: {
                    Image("leftC")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 100)
                }
                .buttonStyle(.plain)

                trainingCard(stat: selectedStat)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCardIndex = (selectedCardIndex + 1) % stats.count
                    }
                } label: {
                    Image("rightC")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 100)

                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 400)
        .background(Color(.darkGreen))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private func trainingCard(stat: StatKind) -> some View {
        VStack {
            HStack {
                Spacer()
                Image(stat.iconNameC)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 10)
            }
            .offset(x: 50)
            Image(stat.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            Text(stat.rawValue + " \(statValue(for: stat))/\(PlayerProgress.maxStat)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            StartButton { showMiniGame = true }
        }
        .padding()
    }

    private func labelValue(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }

    private func statValue(for stat: StatKind) -> Int {
        switch stat {
        case .speed: return progressStore.speed
        case .passing: return progressStore.passing
        case .shooting: return progressStore.shooting
        case .defense: return progressStore.defense
        case .stamina: return progressStore.stamina
        }
    }
}

private struct StartButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Training now")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
    }
}
