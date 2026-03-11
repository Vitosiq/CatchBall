import SwiftUI

struct TrainingMiniGameView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var progressStore: PlayerProgressStore
    let stat: StatKind
    var onDismiss: (() -> Void)?
    var onSwitchToTransfers: (() -> Void)?
    var onGoHome: (() -> Void)?
    private let cornerRadius: CGFloat = 12

    @State private var phase: GamePhase = .countdown
    @State private var countdownValue: String = "4"
    @State private var gameTimeRemaining: Double = 20
    @State private var balls: [FallingBall] = []
    @State private var caughtCount = 0
    @State private var isPaused = false
    @State private var playAreaWidth: CGFloat = 0
    @State private var playAreaHeight: CGFloat = 0
    @State private var gameLoopStarted = false
    @State private var spawnTimer: Timer?
    @State private var gameTimer: Timer?
    @State private var didWin = false
    @State private var showResumeCountdown = false
    @State private var resumeCountdownValue = "4"
    @State private var resumeCountdownTimer: Timer?
    @State private var showLeaveAlert = false
    @AppStorage("hasSeenMiniGameIntro") private var hasSeenMiniGameIntro = false
    @StateObject private var userInfoStore = UserInfoStore()
    @ObservedObject var careerStore: CareerStore

    private var requiredBalls: Int {
        let statValue: Int
        switch stat {
        case .speed: statValue = progressStore.speed
        case .passing: statValue = progressStore.passing
        case .shooting: statValue = progressStore.shooting
        case .defense: statValue = progressStore.defense
        case .stamina: statValue = progressStore.stamina
        }
        return 10 + min(9, statValue / 2)
    }

    private let ballFallSpeed: CGFloat = 890
    private let tickInterval: TimeInterval = 0.04
    private let spawnInterval: TimeInterval = 0.6
    private let ballSize: CGFloat = 100

    var body: some View {
        ZStack {
            GameBackgroundView()
                .ignoresSafeArea()

            if !hasSeenMiniGameIntro {
                VStack {
                    Spacer()
                    introOverlay
                        .padding(.bottom, 100)
                        .padding(.horizontal)
                }

            } else if phase == .countdown {
                countdownOverlay
            } else if phase == .playing {
                ZStack {
                    gameArea
                    if isPaused {
                        pausedOverlay
                    }
                    if showResumeCountdown {
                        resumeCountdownOverlay
                    }
                }
            } else if phase == .result {
                resultOverlay
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Do you really want to finish the level and get out?", isPresented: $showLeaveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Leave", role: .destructive) {
                onDismiss?()
                DispatchQueue.main.async { presentationMode.wrappedValue.dismiss() }
            }
        } message: {
            Text("Your progress for this level will not be saved.")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if phase == .playing {
                        showLeaveAlert = true
                    } else {
                        onDismiss?()
                        DispatchQueue.main.async { presentationMode.wrappedValue.dismiss() }
                    }
                } label: {
                    Image("backButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .buttonStyle(.plain)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if phase == .playing, !showResumeCountdown {
                    Button {
                        if isPaused {
                            startResumeCountdown()
                        } else {
                            isPaused = true
                        }
                    } label: {
                        Image(isPaused ? "play" : "pause")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(.plain)
                }
            }        }
        .onAppear {
            if hasSeenMiniGameIntro {
                startCountdown()
            }
        }
        .onDisappear {
            stopAllTimers()
        }
    }

    private var introOverlay: some View {
        VStack() {
            Text("After pressing \"Start\", the game begins after 3 seconds. You have 20 seconds to catch 10 balls by clicking. Success increases the character's training stats.")
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button("Start training") {
                hasSeenMiniGameIntro = true
                startCountdown()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(Color.orange)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .background(Color(.darkGreen))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var countdownOverlay: some View {
        VStack {
            Text(countdownValue)
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var pausedOverlay: some View {
        ZStack {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
            Button("Play") {
                startResumeCountdown()
            }
            .font(.title)
            .foregroundColor(.white)
            .padding(.horizontal, 48)
            .padding(.vertical, 20)
            .background(Color.orange)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .allowsHitTesting(true)
    }

    private var resumeCountdownOverlay: some View {
        ZStack {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
            Text(resumeCountdownValue)
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(.white)
        }
        .allowsHitTesting(false)
    }

    private var gameArea: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack() {

                ZStack(alignment: .topLeading) {
                    ForEach(balls) { ball in
                        Button {
                            if !isPaused && !showLeaveAlert {
                                catchBall(ball)
                            }
                        } label: {
                            Image("ball")
                                .resizable()
                                .scaledToFit()
                                .rotationEffect(.degrees(ball.rotation))
                        }
                        .buttonStyle(.plain)
                        .frame(width: ballSize, height: ballSize)
                        .contentShape(Circle())
                        .position(x: ball.x, y: ball.y)
                    }
                }
                .frame(width: w, height: h * 0.7)
                .clipped()
                
                VStack {
                    Text(timeString(from: gameTimeRemaining))
                        .font(.title).bold()
                        .foregroundColor(.white)
                        .padding(.top, 60)
                    Spacer()
                    Text("\(caughtCount)/\(requiredBalls)")
                        .font(.title).bold()
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color(.orange))
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        .padding(.bottom, 120)
                }

            }
            .frame(width: w, height: h)
            .onAppear {
                playAreaWidth = w
                playAreaHeight = h
                if !gameLoopStarted {
                    gameLoopStarted = true
                    startGameLoop(width: w, height: h)
                }
            }
        }
    }

    private var resultOverlay: some View {
        ZStack {
            Image("mainBack")
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
            VStack(spacing: 5) {
                HStack {
                    Text("You get \(caughtCount)")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Image("resultBall")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 35)
                }

                Text(didWin
                     ? "Great, you did the drill" : "You didn't do the exercise")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                ZStack {
                    Image("profileCard")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 320)
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
                            .frame(width: 60, height: 60)
                    }
                    .padding(.leading, 150)
                    .padding(.bottom, 100)
                    winsProgressSection
                        .padding(.top, 160)
                }
                
                VStack {
                    HStack {
                        Text(stat.rawValue)
                            .font(.caption)
                            .foregroundColor(.white)
                        Text(didWin ? "+2" : "+0")
                            .font(.caption)
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(currentStatValue)/\(PlayerProgress.maxStat)")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    ProgressView(value: Double(currentStatValue), total: Double(PlayerProgress.maxStat))
                        .frame(width: 160)
                        .tint(.orange)
                        .padding(.top, 2)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color(.darkGreen))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .padding(.horizontal, 80)
                
                if didWin {
                    Button("Go Transfers") {
                        onSwitchToTransfers?()
                        onDismiss?()
                        DispatchQueue.main.async { presentationMode.wrappedValue.dismiss() }
                    }
                    .font(.headline)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                    Button("Go Home") {
                        onGoHome?()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.orange))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                } else {
                    Button("Try again") {
                        restartGame()
                    }
                    .font(.headline)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 40)
                    Button("Go Home") {
                        onGoHome?()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.orange))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 40)
                }
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

    private var currentStatValue: Int {
        switch stat {
        case .speed: return progressStore.speed
        case .passing: return progressStore.passing
        case .shooting: return progressStore.shooting
        case .defense: return progressStore.defense
        case .stamina: return progressStore.stamina
        }
    }

    private func restartGame() {
        stopAllTimers()
        gameLoopStarted = false
        balls = []
        caughtCount = 0
        gameTimeRemaining = 20
        countdownValue = "4"
        phase = .countdown
        startCountdown()
    }

    private func startCountdown() {
        var step = 0
        let steps = ["4", "3", "2", "1", "Go!"]
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            step += 1
            if step < steps.count {
                countdownValue = steps[step]
            } else {
                t.invalidate()
                phase = .playing
                gameTimeRemaining = 20
            }
        }
        .fire()
    }

    private func startResumeCountdown() {
        showResumeCountdown = true
        resumeCountdownValue = "4"
        var step = 0
        let steps = ["4", "3", "2", "1", "Go!"]
        resumeCountdownTimer?.invalidate()
        resumeCountdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            DispatchQueue.main.async {
                step += 1
                if step < steps.count {
                    self.resumeCountdownValue = steps[step]
                } else {
                    t.invalidate()
                    self.resumeCountdownTimer = nil
                    self.showResumeCountdown = false
                    self.isPaused = false
                }
            }
        }
        resumeCountdownTimer?.fire()
    }

    private func startGameLoop(width w: CGFloat, height h: CGFloat) {
        guard w > 0, h > 0 else { return }

        spawnTimer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: true) { _ in
            DispatchQueue.main.async {
                if self.isPaused || self.showLeaveAlert { return }
                let x = CGFloat.random(in: (self.ballSize/2)...(w - self.ballSize/2))
                let rotation = Double.random(in: 0..<360)
                let ball = FallingBall(id: UUID(), x: x, y: -self.ballSize/2, rotation: rotation)
                self.balls = self.balls + [ball]
            }
        }
        spawnTimer?.fire()

        gameTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { _ in
            DispatchQueue.main.async {
                if self.isPaused || self.showLeaveAlert { return }
                self.gameTimeRemaining -= self.tickInterval
                if self.gameTimeRemaining <= 0 {
                    self.endGame()
                    return
                }
                let dy = self.ballFallSpeed * CGFloat(self.tickInterval)
                self.balls = self.balls.compactMap { b in
                    var next = b
                    next.y += dy
                    if next.y > h + self.ballSize { return nil }
                    return next
                }
            }
        }
    }

    private func catchBall(_ ball: FallingBall) {
        balls.removeAll { $0.id == ball.id }
        caughtCount += 1
    }

    private func endGame() {
        stopAllTimers()
        didWin = caughtCount >= requiredBalls
        if didWin {
            progressStore.recordMiniGameWin(stat: stat)
        }
        progressStore.recordGameResult(won: didWin)
        phase = .result
    }

    private func stopAllTimers() {
        spawnTimer?.invalidate()
        spawnTimer = nil
        gameTimer?.invalidate()
        gameTimer = nil
        resumeCountdownTimer?.invalidate()
        resumeCountdownTimer = nil
    }
}

private enum GamePhase {
    case countdown, playing, result
}

private struct FallingBall: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var rotation: Double
}

private func timeString(from seconds: Double) -> String {
    let totalSeconds = Int(max(0, round(seconds)))
    let minutes = totalSeconds / 60
    let secs = totalSeconds % 60
    return String(format: "%02d:%02d", minutes, secs)
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
