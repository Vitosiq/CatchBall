import SwiftUI

struct HowToUseView: View {
    @Environment(\.presentationMode) private var presentationMode
    var onDismiss: (() -> Void)?

    var body: some View {
        ZStack {
            MainBackgroundView()
            VStack(spacing: 24) {
                ScrollView {
                    VStack {
                        Text("How to use")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("In this game, you control the journey of a young American football player trying to break through from amateur levels to the big leagues. Your task is to train him daily, enhance key skills, respond to random game situations, and make decisions that shape his future career. Each training session is a short challenge where you navigate dynamic scenarios, avoid obstacles, create moments, and earn upgrades. As the player becomes stronger, new teams become available, and transfers allow movement between different leagues in search of the best opportunities. The drag-and-drop mechanics are designed for you to easily switch clubs, test your chances, and find the optimal path for progress. Alongside this, your star's stats, mood, and fanbase grow, while mini-games and random events provide chances to earn bonuses and rare upgrades. Monitor progress, analyse results, and maintain steady development — and your player will rise higher until he is ready for the level where the true legend of American football begins.")
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 80)
                    Rectangle()
                        .frame(height: 200)
                        .foregroundStyle(Color.clear)
                    Spacer()
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    onDismiss?()
                    DispatchQueue.main.async {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Image("backButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
