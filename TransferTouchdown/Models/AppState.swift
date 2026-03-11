import Foundation
import SwiftUI

enum AppScreen {
    case splash
    case onboarding
    case startingInfo
    case allSet
    case main
}

@MainActor
class AppState: ObservableObject {
    @Published var currentScreen: AppScreen = .splash
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    @Published var hasCompletedStartingInfo: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedStartingInfo, forKey: "hasCompletedStartingInfo")
        }
    }
    @Published var wasStartingInfoSkipped: Bool {
        didSet {
            UserDefaults.standard.set(wasStartingInfoSkipped, forKey: "wasStartingInfoSkipped")
        }
    }
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.hasCompletedStartingInfo = UserDefaults.standard.bool(forKey: "hasCompletedStartingInfo")
        self.wasStartingInfoSkipped = UserDefaults.standard.bool(forKey: "wasStartingInfoSkipped")
        
        currentScreen = .splash
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        currentScreen = .startingInfo
    }
    
    func completeStartingInfo() {
        hasCompletedStartingInfo = true
        currentScreen = .allSet
    }
    
    func skipStartingInfo() {
        wasStartingInfoSkipped = true
        hasCompletedStartingInfo = true
        currentScreen = .allSet
    }
    
    func goToMain() {
        currentScreen = .main
    }
    
    func navigateToMain() {
        currentScreen = .main
    }

    func resetAllDataAndRestart() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        hasCompletedOnboarding = false
        hasCompletedStartingInfo = false
        wasStartingInfoSkipped = false
        currentScreen = .splash
    }
}
