import SwiftUI

struct StartingInfoView: View {
    @ObservedObject var appState: AppState
    @StateObject private var userInfoStore = UserInfoStore()
    @State private var positionExpanded = false
    @State private var nationalityExpanded = false
    @State private var ageText = ""
    @FocusState private var isKeyboardVisible: Bool
    private var isConfirmEnabled: Bool {
        userInfoStore.userInfo.isComplete
    }

    var body: some View {
        NavigationView {
            ZStack {
                Image("onbBack")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                ScrollView {
                    VStack() {
                        headerSection
                            .padding(.top, 80)
                        nameAndAgeSection
                            .padding(.top, 10)
                        positionSection
                            .padding(.top, 10)
                        nationalitySection
                            .padding(.top, 10)
                        Spacer(minLength: 30)
                        buttonsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 80)
                    Rectangle()
                        .frame(height: 200)
                        .foregroundStyle(Color.clear)
                }
            }
            .preferredColorScheme(.dark)
            .onTapGesture {
                isKeyboardVisible = false
            }
            .navigationBarHidden(true)
            .onAppear {
                if let age = userInfoStore.userInfo.age {
                    ageText = "\(age)"
                }
            }
            .onChange(of: userInfoStore.userInfo.age) { newValue in
                if ageText != (newValue.map { "\($0)" } ?? "") {
                    ageText = newValue.map { "\($0)" } ?? ""
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Starting info")
                .font(.largeTitle)
                .foregroundColor(.white)
                .fontWeight(.bold)
            Text("You must enter all the \ninformation to get started")
                .font(.subheadline)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
    }

    private var nameAndAgeSection: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let spacing: CGFloat = 12
            let nameWidth = (totalWidth - spacing) * 2 / 3
            let ageWidth = (totalWidth - spacing) * 1 / 3
            HStack(alignment: .center, spacing: spacing) {
                
                TextField("Name", text: $userInfoStore.userInfo.name, prompt: Text("Name").foregroundColor(.white.opacity(0.7)))
                    .focused($isKeyboardVisible)
                    .textFieldStyle(.plain)
                    .autocapitalization(.words)
                    .foregroundColor(.white)
                    .tint(.white)
                    .padding()
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .onChange(of: userInfoStore.userInfo.name) { newValue in
                        if newValue.count > UserInfo.maxNameLength {
                            var u = userInfoStore.userInfo
                            u.name = String(newValue.prefix(UserInfo.maxNameLength))
                            userInfoStore.userInfo = u
                        }
                    }
                    .frame(width: nameWidth)

                TextField("Age", text: $ageText, prompt: Text("Age").foregroundColor(.white.opacity(0.7)))
                    .focused($isKeyboardVisible)
                    .textFieldStyle(.plain)
                    .keyboardType(.numberPad)
                    .foregroundColor(.white)
                    .tint(.white)
                    .padding()
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .onChange(of: ageText) { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        ageText = filtered
                        var u = userInfoStore.userInfo
                        if let intValue = Int(filtered) {
                            if intValue > UserInfo.maxAge {
                                u.age = UserInfo.maxAge
                                ageText = "\(UserInfo.maxAge)"
                            } else if intValue >= UserInfo.minAge {
                                u.age = intValue
                            } else {
                                u.age = nil
                            }
                        } else if filtered.isEmpty {
                            u.age = nil
                        }
                        userInfoStore.userInfo = u
                    }
                    .frame(width: ageWidth)
            }
        }
        .frame(height: 52)
    }

    private var positionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { withAnimation(.easeInOut(duration: 0.25)) { positionExpanded.toggle() } }) {
                HStack {
                    VStack {
                        Text("Position")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Text(userInfoStore.userInfo.position.isEmpty ? "Select" : userInfoStore.userInfo.position)
                            .font(.subheadline)
                            .foregroundColor(userInfoStore.userInfo.position.isEmpty ? .white.opacity(0.7) : .white)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(positionExpanded ? 180 : 0))
                }
                .padding()
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            if positionExpanded {
                VStack(spacing: 0) {
                    ForEach(FootballPosition.allCases, id: \.self) { pos in
                        let isSelected = userInfoStore.userInfo.position == pos.rawValue
                        Button(action: {
                            var u = userInfoStore.userInfo
                            u.position = pos.rawValue
                            userInfoStore.userInfo = u
                            withAnimation(.easeInOut(duration: 0.2)) { positionExpanded = false }
                        }) {
                            HStack {
                                Text(pos.rawValue)
                                    .foregroundColor(.white)
                                Spacer()
                                Text(isSelected ? "Selected" : "Choose")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(isSelected ? .orange : .white)
                                    .frame(width: 70, height: 30)
                                    .background(isSelected ? Color.green.opacity(0.25) : Color.orange)
                                    .cornerRadius(6)
                            }
                            .padding(.horizontal, 36)
                            .padding(.vertical, 12)
                        }
                        .background(Color.clear)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 1)
                )
                .padding(.top, 4)
            }
        }
    }

    private var nationalitySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { withAnimation(.easeInOut(duration: 0.25)) { nationalityExpanded.toggle() } }) {
                HStack(spacing: 12) {
                    if let selected = NationalityOption.allCases.first(where: { $0.rawValue == userInfoStore.userInfo.nationality }) {
                        Text(selected.flag)
                            .font(.title2)
                    } else {
                        Text("🌐")
                            .font(.title2)
                    }
                    VStack(alignment: .leading) {
                        Text("Nationality")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Text(userInfoStore.userInfo.nationality.isEmpty ? "Select" : userInfoStore.userInfo.nationality)
                            .font(.subheadline)
                            .foregroundColor(userInfoStore.userInfo.nationality.isEmpty ? .white.opacity(0.7) : .white)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(nationalityExpanded ? 180 : 0))
                }
                .padding()
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            if nationalityExpanded {
                VStack(spacing: 0) {
                    ForEach(NationalityOption.allCases, id: \.self) { option in
                        let isSelected = userInfoStore.userInfo.nationality == option.rawValue
                        Button(action: {
                            var u = userInfoStore.userInfo
                            u.nationality = option.rawValue
                            userInfoStore.userInfo = u
                            withAnimation(.easeInOut(duration: 0.2)) { nationalityExpanded = false }
                        }) {
                            HStack(spacing: 12) {
                                Text(option.flag)
                                    .font(.title2)
                                Text(option.rawValue)
                                    .foregroundColor(.white)
                                Spacer()
                                Text(isSelected ? "Selected" : "Choose")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(isSelected ? .orange : .white)
                                    .frame(width: 70, height: 30)
                                    .background(isSelected ? Color.green.opacity(0.25) : Color.orange)
                                    .cornerRadius(6)
                            }
                            .padding(.horizontal, 36)
                            .padding(.vertical, 12)
                        }
                        .background(Color.clear)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 1)
                )
                .padding(.top, 4)
            }
        }
    }

    private var buttonsSection: some View {
        HStack(spacing: 16) {

            Button(action: {
                userInfoStore.setDefaultAndSkip()
                appState.skipStartingInfo()
            }) {
                Text("Skip")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isConfirmEnabled ? Color.white : Color.white)
                    .cornerRadius(12)
            }
            
            Button(action: {
                userInfoStore.save()
                appState.completeStartingInfo()
            }) {
                Text("Confirm")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isConfirmEnabled ? Color.orange : Color.gray)
                    .cornerRadius(6)
            }
            .disabled(!isConfirmEnabled)
            .animation(.easeInOut(duration: 0.2), value: isConfirmEnabled)
        }
        .padding(.top, 8)
    }
}
