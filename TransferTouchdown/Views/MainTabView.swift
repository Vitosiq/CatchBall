import SwiftUI

enum MainTab: Int, CaseIterable {
    case home = 0
    case transfers
    case training
    case progress
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .transfers: return "Transfers"
        case .training: return "Training"
        case .progress: return "Progress"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house"
        case .transfers: return "arrow.left.arrow.right"
        case .training: return "gamecontroller"
        case .progress: return "chart.bar"
        case .settings: return "gearshape"
        }
    }
}

struct MainTabView: View {
    @ObservedObject var appState: AppState
    @StateObject private var progressStore = PlayerProgressStore()
    @StateObject private var careerStore = CareerStore()
    @State private var selectedTab: MainTab = .home
    @State private var hideTabBar = false

    private let tabBarHeight: CGFloat = 70
    private let tabBarCornerRadius: CGFloat = 12
    private let tabBarGreen = Color.darkGreen

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                tabContent(
                    MainView(
                        onSelectTab: { selectedTab = $0 },
                        progressStore: progressStore,
                        careerStore: careerStore
                    ),
                    for: .home
                )
                tabContent(TransfersView(progressStore: progressStore, careerStore: careerStore), for: .transfers)
                tabContent(
                    TrainingView(
                        progressStore: progressStore,
                        careerStore: careerStore,
                        hideTabBar: $hideTabBar,
                        onSwitchToTransfers: { selectedTab = .transfers },
                        onSwitchToHome: { selectedTab = .home }
                    ),
                    for: .training
                )
                tabContent(AppProgressView(progressStore: progressStore, careerStore: careerStore), for: .progress)
                tabContent(SettingsView(appState: appState, progressStore: progressStore, careerStore: careerStore), for: .settings)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            customTabBar
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private func tabContent<Content: View>(_ content: Content, for tab: MainTab) -> some View {
        content
            .opacity(selectedTab == tab ? 1 : 0)
            .allowsHitTesting(selectedTab == tab)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.rawValue) { tab in
                tabItem(tab: tab)
            }
        }
        .frame(height: tabBarHeight)
        .frame(maxWidth: .infinity)
        .background(tabBarGreen)
        .clipShape(RoundedRectangle(cornerRadius: tabBarCornerRadius))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .opacity(hideTabBar ? 0 : 1)
        .allowsHitTesting(!hideTabBar)
    }

    private func tabItem(tab: MainTab) -> some View {
        let isSelected = selectedTab == tab
        let color: Color = isSelected ? .white : .gray

        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 22, weight: .medium))
                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
