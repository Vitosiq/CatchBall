import Foundation

struct PlayerProgress: Codable, Equatable {
    var totalProgressPoints: Int
    var speed: Int
    var passing: Int
    var shooting: Int
    var defense: Int
    var stamina: Int

    static let maxProgressPoints = 160
    static let pointsPerSublevel = 2
    static let sublevelsPerMainLevel = 4
    static let sublevelsTotal = 16
    static let pointsPerMainLevel = 40
    static let maxStat = 100
    static let statPerGame = 2

    var totalLevelPercentage: Int {
        let sum = speed + passing + shooting + defense + stamina
        return sum / 5
    }

    var mainLevel: Int {
        let level = (totalProgressPoints / Self.pointsPerMainLevel) + 1
        return min(5, max(1, level))
    }

    var completedSublevels: Int {
        min(Self.sublevelsTotal, totalProgressPoints / Self.pointsPerSublevel)
    }

    init(
        totalProgressPoints: Int = 0,
        speed: Int = 0,
        passing: Int = 0,
        shooting: Int = 0,
        defense: Int = 0,
        stamina: Int = 0
    ) {
        self.totalProgressPoints = min(Self.maxProgressPoints, max(0, totalProgressPoints))
        self.speed = min(Self.maxStat, max(0, speed))
        self.passing = min(Self.maxStat, max(0, passing))
        self.shooting = min(Self.maxStat, max(0, shooting))
        self.defense = min(Self.maxStat, max(0, defense))
        self.stamina = min(Self.maxStat, max(0, stamina))
    }

    mutating func addProgressPoints(_ points: Int) {
        totalProgressPoints = min(Self.maxProgressPoints, totalProgressPoints + points)
    }

    mutating func addStat(_ stat: StatKind, amount: Int = statPerGame) {
        switch stat {
        case .speed: speed = min(Self.maxStat, speed + amount)
        case .passing: passing = min(Self.maxStat, passing + amount)
        case .shooting: shooting = min(Self.maxStat, shooting + amount)
        case .defense: defense = min(Self.maxStat, defense + amount)
        case .stamina: stamina = min(Self.maxStat, stamina + amount)
        }
    }
}

enum StatKind: String, CaseIterable, Codable {
    case speed = "Speed"
    case passing = "Passing"
    case shooting = "Shooting"
    case defense = "Defense"
    case stamina = "Stamina"
    
    var iconName: String {
        switch self {
        case .speed:
            return "speed"
        case .passing:
            return "passing"
        case .shooting:
            return "shooting"
        case .defense:
            return "defense"
        case .stamina:
            return "stamina"
        }
    }
    
    var iconNameC: String {
        switch self {
        case .speed:
            return "speedC"
        case .passing:
            return "passingC"
        case .shooting:
            return "shootingC"
        case .defense:
            return "defenseC"
        case .stamina:
            return "staminaC"
        }
    }

}
