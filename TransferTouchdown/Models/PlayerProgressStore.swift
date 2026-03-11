import Foundation

struct GameHistoryEntry: Codable {
    let date: Date
    let won: Bool
}

/// Day status for the 7-day streak display.
/// - won: User logged in and did at least one workout that day.
/// - lost: Day has passed (or is today); user did not do a workout (did not log in or did not play minigame).
/// - notPlayed: Day has not yet arrived; no result.
enum DayStatus {
    case won
    case lost
    case notPlayed
}

@MainActor
final class PlayerProgressStore: ObservableObject {
    @Published private(set) var progress: PlayerProgress
    @Published private(set) var gameHistory: [GameHistoryEntry] = []

    private let key = "playerProgress"
    private let gameHistoryKey = "playerGameHistory"
    private let cycleStartKey = "playerProgressCycleStart"
    private let workoutDaysKey = "playerProgressWorkoutDays"
    private let winsTowardTransferKey = "playerProgressWinsTowardTransfer"
    private let maxHistoryEntries = 100
    private let cycleLength = 7

    /// Max value for the wins progress bar (0/4 … 4/4). Purely visual; not connected to transfers.
    static let winsProgressBarMax = 4

    private var cycleStartDate: Date
    private var workoutDoneDayIds: [String]

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone.current
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(PlayerProgress.self, from: data) {
            self.progress = decoded
        } else {
            self.progress = PlayerProgress()
        }
        if let data = UserDefaults.standard.data(forKey: gameHistoryKey),
           let decoded = try? JSONDecoder().decode([GameHistoryEntry].self, from: data) {
            self.gameHistory = decoded
        } else {
            self.gameHistory = []
        }
        let calendar = Calendar.current
        if let interval = UserDefaults.standard.object(forKey: cycleStartKey) as? Double {
            self.cycleStartDate = Date(timeIntervalSince1970: interval)
        } else {
            self.cycleStartDate = calendar.startOfDay(for: Date())
        }
        self.workoutDoneDayIds = UserDefaults.standard.stringArray(forKey: workoutDaysKey) ?? []
        let stored = UserDefaults.standard.integer(forKey: winsTowardTransferKey)
        self.winsTowardNextTransfer = max(0, min(Self.winsProgressBarMax, stored))
        ensureCycle(calendar: calendar)
    }

    @Published private(set) var winsTowardNextTransfer: Int = 0

    func save() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func saveGameHistory() {
        guard let data = try? JSONEncoder().encode(gameHistory) else { return }
        UserDefaults.standard.set(data, forKey: gameHistoryKey)
    }

    private func saveCycleAndWorkoutDays() {
        UserDefaults.standard.set(cycleStartDate.timeIntervalSince1970, forKey: cycleStartKey)
        UserDefaults.standard.set(workoutDoneDayIds, forKey: workoutDaysKey)
    }

    private func saveWinsTowardTransfer() {
        UserDefaults.standard.set(winsTowardNextTransfer, forKey: winsTowardTransferKey)
    }

    private func dayId(for date: Date) -> String {
        Self.dayFormatter.string(from: date)
    }

    /// Advance cycle if we are past the 7-day window; reset and start a new cycle.
    private func ensureCycle(calendar: Calendar) {
        let today = calendar.startOfDay(for: Date())
        guard let cycleEnd = calendar.date(byAdding: .day, value: cycleLength - 1, to: cycleStartDate) else { return }
        if today > cycleEnd {
            cycleStartDate = today
            workoutDoneDayIds = workoutDoneDayIds.filter { dayId in
                guard let d = Self.dayFormatter.date(from: dayId) else { return false }
                return d >= today
            }
            saveCycleAndWorkoutDays()
            objectWillChange.send()
        }
    }

    func recordMiniGameWin(stat: StatKind) {
        progress.addProgressPoints(PlayerProgress.pointsPerSublevel)
        progress.addStat(stat)
        save()
    }

    func recordGameResult(won: Bool) {
        gameHistory.append(GameHistoryEntry(date: Date(), won: won))
        if gameHistory.count > maxHistoryEntries {
            gameHistory.removeFirst(gameHistory.count - maxHistoryEntries)
        }
        saveGameHistory()

        let calendar = Calendar.current
        ensureCycle(calendar: calendar)
        let todayId = dayId(for: Date())
        if !workoutDoneDayIds.contains(todayId) {
            workoutDoneDayIds.append(todayId)
            saveCycleAndWorkoutDays()
        }
        if won {
            winsTowardNextTransfer = min(Self.winsProgressBarMax, winsTowardNextTransfer + 1)
            saveWinsTowardTransfer()
        }
    }

    /// Resets the wins progress bar (e.g. after completing a transfer). Not used to gate transfers.
    func resetWinsTowardNextTransfer() {
        winsTowardNextTransfer = 0
        saveWinsTowardTransfer()
    }

    /// Status for each of the 7 days in the current cycle. Updated daily; cycle resets every 7 days.
    var last7DaysStatus: [DayStatus] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        ensureCycle(calendar: calendar)
        var result: [DayStatus] = []
        for index in 0..<cycleLength {
            guard let dayDate = calendar.date(byAdding: .day, value: index, to: cycleStartDate) else {
                result.append(.lost)
                continue
            }
            if dayDate > today {
                result.append(.notPlayed)
            } else if workoutDoneDayIds.contains(dayId(for: dayDate)) {
                result.append(.won)
            } else {
                result.append(.lost)
            }
        }
        return result
    }

    var totalLevelPercentage: Int { progress.totalLevelPercentage }
    var mainLevel: Int { progress.mainLevel }
    var speed: Int { progress.speed }
    var passing: Int { progress.passing }
    var shooting: Int { progress.shooting }
    var defense: Int { progress.defense }
    var stamina: Int { progress.stamina }
}
