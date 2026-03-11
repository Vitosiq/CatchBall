import Foundation

struct UserInfo: Equatable {
    var name: String
    var age: Int?
    var position: String
    var nationality: String
    
    static let maxNameLength = 14
    static let minAge = 1
    static let maxAge = 99

    var isComplete: Bool {
        let nameValid = !name.trimmingCharacters(in: .whitespaces).isEmpty && name.count <= Self.maxNameLength
        guard let a = age, a >= Self.minAge, a <= Self.maxAge else { return false }
        return nameValid && !position.isEmpty && !nationality.isEmpty
    }

    static let defaultForSkip = UserInfo(
        name: "Player",
        age: 25,
        position: "QB",
        nationality: "United States"
    )
}

enum FootballPosition: String, CaseIterable {
    case qb = "QB"
    case rb = "RB"
    case fb = "FB"
    case wr = "WR"
    case te = "TE"
    case ot = "OT"
    case og = "OG"
    case c = "C"
    case de = "DE"
    case dt = "DT"
    case lb = "LB"
    case cb = "CB"
    case s = "S"
    case k = "K"
    case p = "P"
}

enum NationalityOption: String, CaseIterable {
    case unitedStates = "United States"
    case canada = "Canada"
    case mexico = "Mexico"
    case unitedKingdom = "United Kingdom"
    case germany = "Germany"
    case france = "France"
    case spain = "Spain"
    case italy = "Italy"
    case brazil = "Brazil"
    case argentina = "Argentina"
    case australia = "Australia"
    case japan = "Japan"
    case southKorea = "South Korea"
    case india = "India"
    case nigeria = "Nigeria"
    case other = "Other"

    var flag: String {
        switch self {
        case .unitedStates: return "🇺🇸"
        case .canada: return "🇨🇦"
        case .mexico: return "🇲🇽"
        case .unitedKingdom: return "🇬🇧"
        case .germany: return "🇩🇪"
        case .france: return "🇫🇷"
        case .spain: return "🇪🇸"
        case .italy: return "🇮🇹"
        case .brazil: return "🇧🇷"
        case .argentina: return "🇦🇷"
        case .australia: return "🇦🇺"
        case .japan: return "🇯🇵"
        case .southKorea: return "🇰🇷"
        case .india: return "🇮🇳"
        case .nigeria: return "🇳🇬"
        case .other: return "🌐"
        }
    }
}

@MainActor
class UserInfoStore: ObservableObject {
    @Published var userInfo: UserInfo

    private let userDefaultsKey = "userInfo"

    init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(UserInfo.self, from: data) {
            self.userInfo = decoded
        } else {
            let wasSkipped = UserDefaults.standard.bool(forKey: "wasStartingInfoSkipped")
            self.userInfo = wasSkipped ? UserInfo.defaultForSkip : UserInfo(
                name: "",
                age: nil,
                position: "",
                nationality: ""
            )
        }
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(userInfo) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    func setDefaultAndSkip() {
        userInfo = UserInfo.defaultForSkip
        save()
    }
}

extension UserInfo: Codable {}
