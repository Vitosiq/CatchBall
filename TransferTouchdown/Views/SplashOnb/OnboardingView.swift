import SwiftUI

struct OnboardingView: View {
    @ObservedObject var appState: AppState
    @State private var currentPage: Int = 0
    
    private let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "onb1",
            title: "Welcome",
            description: "Train your rookie and help him rise from \nnewcomer to future football star"
        ),
        OnboardingPage(
            imageName: "onb2",
            title: "Training",
            description: "Complete fast drills to improve skills and \nboost your athlete’s performance"
        ),
        OnboardingPage(
            imageName: "onb3",
            title: "Transfers",
            description: "Move teams, choose stronger clubs, and \npush your athlete’s career higher"
        )
    ]
    
    var body: some View {
        ZStack {
            Image("onbBack")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        OnboardingPageView(page: onboardingPages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                Button(action: {
                    if currentPage < onboardingPages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        appState.completeOnboarding()
                    }
                }) {
                    Text(currentPage == onboardingPages.count - 1 ? "Get Started" : "Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 100)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct OnboardingPage {
    let imageName: String
    let title: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 400)
                .padding(.top, 60)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 20)
            
            Spacer()
        }
    }
}
