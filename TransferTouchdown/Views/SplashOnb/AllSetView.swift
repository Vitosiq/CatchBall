import SwiftUI

struct AllSetView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        ZStack {
            Image("onbBack")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Hello coach")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Now you are my coach, help me \nbecome the best of the best")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Image("allSet")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 330)
                Button(action: { appState.goToMain() }) {
                    Text("Start")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
            }
        }
        .preferredColorScheme(.dark)
    }
}
