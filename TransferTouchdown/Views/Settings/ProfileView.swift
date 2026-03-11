import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var userInfoStore = UserInfoStore()
    @State private var positionExpanded = false
    @State private var nationalityExpanded = false
    @State private var ageText = ""
    @State private var initialUserInfo: UserInfo?
    @State private var showLeaveAlert = false
    var onDismiss: (() -> Void)?
    @FocusState private var isKeyboardVisible: Bool
    @ObservedObject var progressStore: PlayerProgressStore
    private let cornerRadius: CGFloat = 12
    @ObservedObject var careerStore: CareerStore

    private var hasUnsavedChanges: Bool {
        guard let initial = initialUserInfo else { return false }
        return userInfoStore.userInfo != initial
    }

    private var isSaveEnabled: Bool {
        userInfoStore.userInfo.isComplete
    }

    var body: some View {
        ZStack {
            Image("mainBack")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 10) {
                    Text("Profile")
                        .font(.title).bold()
                        .foregroundStyle(.white)
                    ZStack {
                        Image("cardProfile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 330, height: 230)
                        
                        VStack(spacing: 0) {
                            Text(userInfoStore.userInfo.name.isEmpty ? "Player" : userInfoStore.userInfo.name)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            VStack(spacing: 0) {
                                statRow(name: StatKind.speed.rawValue, value: progressStore.speed)
                                statRow(name: StatKind.passing.rawValue, value: progressStore.passing)
                                statRow(name: StatKind.shooting.rawValue, value: progressStore.shooting)
                                statRow(name: StatKind.defense.rawValue, value: progressStore.defense)
                                statRow(name: StatKind.stamina.rawValue, value: progressStore.stamina)
                            }
                        }
                        .frame(width: 100, height: 200)
                        .padding(.leading, 170)
                        VStack(spacing: 4) {
                            Text("\(progressStore.totalLevelPercentage)")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(userInfoStore.userInfo.position.isEmpty ? "—" : userInfoStore.userInfo.position)
                                .font(.caption)
                                .foregroundColor(.white)
                            Text(NationalityOption(rawValue: userInfoStore.userInfo.nationality)?.flag ?? "🌐")
                                .font(.headline)
                            Image(careerStore.currentTeam.logoName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        .padding(.bottom, 50)
                        .padding(.trailing, 20)
                        winsProgressSection
                            .padding(.top, 110)
                            .padding(.trailing, 120)
                        
                    }
                    nameAndAgeSection
                    positionSection
                    nationalitySection
                    Spacer(minLength: 30)
                    saveButton
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
        .onAppear {
            initialUserInfo = userInfoStore.userInfo
            if let age = userInfoStore.userInfo.age {
                ageText = "\(age)"
            } else {
                ageText = ""
            }
        }
        .alert("Unsaved changes", isPresented: $showLeaveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Leave", role: .destructive) {
                onDismiss?()
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text("You have not saved the data, if you exit you will lose it!")
        }
        .onChange(of: userInfoStore.userInfo.age) { newValue in
            if ageText != (newValue.map { "\($0)" } ?? "") {
                ageText = newValue.map { "\($0)" } ?? ""
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if hasUnsavedChanges {
                        showLeaveAlert = true
                    } else {
                        onDismiss?()
                        DispatchQueue.main.async {
                            presentationMode.wrappedValue.dismiss()
                        }
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
    
    private var winsProgressSection: some View {
        let filled = progressStore.winsTowardNextTransfer
        let total = PlayerProgressStore.winsProgressBarMax
        return HStack(spacing: 2) {
            ForEach(0..<total, id: \.self) { index in
                ParallelogramSegment(filled: index < filled)
            }
            .padding(.leading, 5)
            HStack(spacing: 0) {
                Text("\(filled)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
                Text("/\(total)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(.leading, 5)
        }
    }
    
    private func statRow(name: String, value: Int) -> some View {
        VStack {
            HStack {
                Text(name)
                    .font(.caption)
                    .foregroundColor(.white)
                Spacer()
                Text("\(value)/\(PlayerProgress.maxStat)")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            ProgressView(value: Double(value), total: Double(PlayerProgress.maxStat))
                .frame(width: 120)
                .tint(.orange)
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
                    VStack(alignment: .leading) {
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

    private var saveButton: some View {
        Button(action: {
            userInfoStore.save()
            onDismiss?()
            DispatchQueue.main.async {
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            Text("Save")
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 30)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSaveEnabled ? Color.orange : Color.gray)
                .cornerRadius(6)
        }
        .disabled(!isSaveEnabled)
        .animation(.easeInOut(duration: 0.2), value: isSaveEnabled)
        .padding(.top, 8)
    }
}

private struct ParallelogramShape: Shape {
    var skew: CGFloat = 4

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: skew, y: 0))
        path.addLine(to: CGPoint(x: w + skew, y: 0))
        path.addLine(to: CGPoint(x: w - skew, y: h))
        path.addLine(to: CGPoint(x: -skew, y: h))
        path.closeSubpath()
        return path
    }
}

private struct ParallelogramSegment: View {
    let filled: Bool

    var body: some View {
        Rectangle()
            .fill(filled ? Color.orange : Color.gray)
            .clipShape(ParallelogramShape(skew: 3))
            .frame(height: 8)
            .frame(width: 15)
    }
}
