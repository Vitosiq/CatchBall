import Foundation

struct Team: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let logoName: String
    let stars: Int

    var starText: String { String(repeating: "★", count: stars) }

    enum CodingKeys: String, CodingKey { case id, name, logoName, stars }

    init(id: String, name: String, logoName: String, stars: Int) {
        self.id = id
        self.name = name
        self.logoName = logoName
        self.stars = min(5, max(1, stars))
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        stars = try c.decode(Int.self, forKey: .stars)
        logoName = try c.decodeIfPresent(String.self, forKey: .logoName) ?? id
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(logoName, forKey: .logoName)
        try c.encode(stars, forKey: .stars)
    }
}

private struct TransferSlotsData: Codable {
    var s0: Team?
    var s1: Team?
    var s2: Team?
    var s3: Team?
    init(slots: [Team?]) {
        s0 = slots.count > 0 ? slots[0] : nil
        s1 = slots.count > 1 ? slots[1] : nil
        s2 = slots.count > 2 ? slots[2] : nil
        s3 = slots.count > 3 ? slots[3] : nil
    }
    var slots: [Team?] { [s0, s1, s2, s3] }
}

@MainActor
final class CareerStore: ObservableObject {
    @Published private(set) var startingTeam: Team
    @Published private(set) var transferSlots: [Team?]

    private let key = "careerTransfers"
    private let startingTeamKey = "careerStartingTeam"

    static let defaultStartingTeam = Team(id: "charger", name: "Charger", logoName: "charger", stars: 1)

    private static let teamsByStars: [Int: [Team]] = [
        2: [
            Team(id: "wolves", name: "Wolves", logoName: "wolves", stars: 2),
            Team(id: "titans", name: "Titans", logoName: "titans", stars: 2),
            Team(id: "raptors", name: "Raptors", logoName: "raptors", stars: 2)
        ],
        3: [
            Team(id: "vipers", name: "Vipers", logoName: "vipers", stars: 3),
            Team(id: "chargers", name: "Chargers", logoName: "chargers", stars: 3),
            Team(id: "storm", name: "Storm", logoName: "storm", stars: 3)
        ],
        4: [
            Team(id: "blaze", name: "Blaze", logoName: "blaze", stars: 4),
            Team(id: "falcons", name: "Falcons", logoName: "falcons", stars: 4)
        ],
        5: [
            Team(id: "hammers", name: "Hammers", logoName: "hammers", stars: 5),
            Team(id: "tornadoes", name: "Tornadoes", logoName: "tornadoes", stars: 5)
        ]
    ]

    init() {
        if let data = UserDefaults.standard.data(forKey: startingTeamKey),
           let t = try? JSONDecoder().decode(Team.self, from: data) {
            self.startingTeam = t.id == "start" ? Self.defaultStartingTeam : t
        } else {
            self.startingTeam = Self.defaultStartingTeam
        }
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(TransferSlotsData.self, from: data) {
            self.transferSlots = decoded.slots
        } else {
            self.transferSlots = [nil, nil, nil, nil]
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(startingTeam) {
            UserDefaults.standard.set(data, forKey: startingTeamKey)
        }
        let slotsData = TransferSlotsData(slots: transferSlots)
        if let data = try? JSONEncoder().encode(slotsData) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    var currentTeam: Team {
        transferSlots.last(where: { $0 != nil }).flatMap { $0 } ?? startingTeam
    }

    var transfersUsed: Int {
        transferSlots.filter { $0 != nil }.count
    }

    var hasReachedGoal: Bool {
        transferSlots.allSatisfy { $0 != nil }
    }

    /// Wins required in minigame to unlock 2nd, 3rd, 4th transfer. First transfer has no win requirement.
    static let winsRequiredForNextTransfer = 4

    func currentTransferSlotIndex(mainLevel: Int, winsTowardNextTransfer: Int) -> Int? {
        guard !hasReachedGoal else { return nil }
        for i in 0..<4 {
            guard transferSlots[i] == nil else { continue }
            if i == 0 {
                if mainLevel >= 1 { return i }
            } else {
                // Slots 1–3 unlock by 4 minigame wins only (no level requirement)
                if winsTowardNextTransfer >= Self.winsRequiredForNextTransfer {
                    return i
                }
            }
        }
        return nil
    }

    func availableTeamsForCurrentSlot(mainLevel: Int, winsTowardNextTransfer: Int) -> [Team] {
        guard let slotIndex = currentTransferSlotIndex(mainLevel: mainLevel, winsTowardNextTransfer: winsTowardNextTransfer) else { return [] }
        return teamsForSlotDisplay(slotIndex: slotIndex)
    }

    func teamsForSlotDisplay(slotIndex: Int) -> [Team] {
        guard slotIndex >= 0, slotIndex < 4 else { return [] }
        let stars = slotIndex + 2
        let pool = Self.teamsByStars[stars] ?? []
        return pool.shuffled()
    }

    func selectTeam(_ team: Team, forSlotIndex slotIndex: Int) {
        guard slotIndex >= 0, slotIndex < 4 else { return }
        var newSlots = transferSlots
        newSlots[slotIndex] = team
        transferSlots = newSlots
        save()
    }

    func selectRandomTeamForCurrentSlot(mainLevel: Int, winsTowardNextTransfer: Int) {
        let teams = availableTeamsForCurrentSlot(mainLevel: mainLevel, winsTowardNextTransfer: winsTowardNextTransfer)
        guard let team = teams.randomElement(), let slotIndex = currentTransferSlotIndex(mainLevel: mainLevel, winsTowardNextTransfer: winsTowardNextTransfer) else { return }
        selectTeam(team, forSlotIndex: slotIndex)
    }
}
