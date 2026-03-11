import SwiftUI

struct RemoveAdsView: View {
    @Environment(\.presentationMode) private var presentationMode
    var onDismiss: (() -> Void)?
    @State private var adsRemoved = false

    var body: some View {
        ZStack {
            MainBackgroundView()
            VStack(spacing: 24) {
                ScrollView {
                    VStack {
                        Text("Remove ads")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("We want to keep the game free for everyone. But creating new levels, updates, graphics, and maintaining servers takes resources. Ads are our main source of support, allowing us to keep improving the game. We’ve made sure ads are short and not too intrusive, so they don’t spoil your gameplay. Every ad you watch helps us pay the team, add new features, and keep the content exciting. If you prefer playing without ads, you can always disable them through an in-app purchase. But remember: ads are what make the game free and accessible to players all around the world.")
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button {
                            adsRemoved.toggle()
                        } label: {
                            Text(adsRemoved ? "Turn on ads" : "Remove ads")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 16)
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
