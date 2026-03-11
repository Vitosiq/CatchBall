import SwiftUI

struct SplashView: View {
    @ObservedObject var appState: AppState
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Image("splashBack")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Spacer()
                
                Image(systemName: "gamecontroller")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Spacer()
                HStack {
                    Image("spinner")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(rotation))
                        .rotationEffect(.degrees(rotation))
                        .onAppear {
                            withAnimation(
                                .linear(duration: 1.5)
                                    .repeatForever(autoreverses: false)
                            ) {
                                rotation = 360
                            }
                        }
                    Text("Loading...")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 100)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                if appState.hasCompletedOnboarding {
                    if appState.hasCompletedStartingInfo || appState.wasStartingInfoSkipped {
                        appState.currentScreen = .main
                    } else {
                        appState.currentScreen = .startingInfo
                    }
                } else {
                    appState.currentScreen = .onboarding
                }
            }
        }
    }
}
