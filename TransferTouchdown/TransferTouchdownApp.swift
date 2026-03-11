import SwiftUI

@main
struct TransferTouchdownApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                switch appState.currentScreen {
                case .splash:
                    SplashView(appState: appState)
                case .onboarding:
                    OnboardingView(appState: appState)
                case .startingInfo:
                    StartingInfoView(appState: appState)
                case .allSet:
                    AllSetView(appState: appState)
                case .main:
                    MainTabView(appState: appState)
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    NotificationManager.shared.schedule24HourReminderIfEnabled()
                }
            }
        }
    }
}
