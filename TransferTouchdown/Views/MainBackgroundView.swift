import SwiftUI

struct MainBackgroundView: View {
    var body: some View {
        Image("mainBack")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

struct GameBackgroundView: View {
    var body: some View {
        Image("trainingBack")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}
