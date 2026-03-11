import Foundation
import UserNotifications

struct NotificationHistoryItem: Codable, Identifiable {
    let id: String
    let title: String
    let body: String
    let date: Date
}

final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let reminderIdentifier = "reminder24h"
    private let reminderTitle = "Come back and train"
    private let reminderBody = "You haven't trained your character in a long time, don't forget about him!"
    private let historyKey = "notificationHistory"
    private let lastScheduledFireDateKey = "lastScheduledReminderFireDate"

    private init() {}

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    func schedule24HourReminderIfEnabled() {
        guard UserDefaults.standard.bool(forKey: "notificationsEnabled") else {
            UserDefaults.standard.removeObject(forKey: lastScheduledFireDateKey)
            cancel24HourReminder()
            return
        }

        center.getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            guard settings.authorizationStatus == .authorized else { return }

            self.center.getPendingNotificationRequests { [weak self] pending in
                guard let self = self else { return }
                let hadPendingReminder = pending.contains { $0.identifier == self.reminderIdentifier }
                let lastFireDate = UserDefaults.standard.object(forKey: self.lastScheduledFireDateKey) as? Double
                let lastFire = lastFireDate.map { Date(timeIntervalSince1970: $0) }

                if !hadPendingReminder, let fire = lastFire, fire < Date() {
                    self.addToHistory(title: self.reminderTitle, body: self.reminderBody, date: fire)
                }

                self.center.removePendingNotificationRequests(withIdentifiers: [self.reminderIdentifier])

                let content = UNMutableNotificationContent()
                content.title = self.reminderTitle
                content.body = self.reminderBody
                content.sound = .default

                let fireDate = Date().addingTimeInterval(24 * 60 * 60)
                UserDefaults.standard.set(fireDate.timeIntervalSince1970, forKey: self.lastScheduledFireDateKey)

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 24 * 60 * 60, repeats: false)
                let request = UNNotificationRequest(identifier: self.reminderIdentifier, content: content, trigger: trigger)

                self.center.add(request, withCompletionHandler: nil)
            }
        }
    }

    func cancel24HourReminder() {
        UserDefaults.standard.removeObject(forKey: lastScheduledFireDateKey)
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
    }


    func addToHistory(title: String, body: String, date: Date) {
        var list = getHistory()
        list.insert(NotificationHistoryItem(id: UUID().uuidString, title: title, body: body, date: date), at: 0)
        saveHistory(list)
    }

    func getHistory() -> [NotificationHistoryItem] {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let decoded = try? JSONDecoder().decode([NotificationHistoryItem].self, from: data) else {
            return []
        }
        return decoded.sorted { $0.date > $1.date }
    }

    func clearHistory() {
        UserDefaults.standard.removeObject(forKey: historyKey)
    }

    private func saveHistory(_ list: [NotificationHistoryItem]) {
        guard let data = try? JSONEncoder().encode(list) else { return }
        UserDefaults.standard.set(data, forKey: historyKey)
    }
}
