import Combine
import Foundation
import UserNotifications

/// The nightly check-in. One repeating local notification with two actions: "Dry tonight" logs
/// without opening the app; "I had a drink" opens the app on the log sheet.
@MainActor
final class ReminderManager: NSObject, ObservableObject {
    static let categoryID = "damp.checkin"
    static let dryActionID = "damp.checkin.dry"
    static let drankActionID = "damp.checkin.drank"
    static let requestID = "damp.checkin.daily"

    @Published private(set) var isAuthorized = false

    /// Set by the app. Called on the main actor when the user taps "Dry tonight" on the notification.
    var onDryNight: (() -> Void)?
    /// Called when the user taps "I had a drink"; the app opens and shows the log sheet.
    var onDrank: (() -> Void)?

    override init() {
        super.init()
        let dry = UNNotificationAction(identifier: Self.dryActionID, title: "Dry tonight ✓", options: [])
        let drank = UNNotificationAction(identifier: Self.drankActionID, title: "I had a drink", options: [.foreground])
        let category = UNNotificationCategory(identifier: Self.categoryID, actions: [dry, drank], intentIdentifiers: [])
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([category])
        center.delegate = self
    }

    func refreshStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
    }

    /// Asks once. Returns true when granted.
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            Analytics.track(granted ? .remindersAuthorized : .remindersDenied)
            return granted
        } catch {
            isAuthorized = false
            Analytics.track(.remindersDenied, ["error": String(describing: error)])
            return false
        }
    }

    /// (Re)schedules the daily check-in at `minutesAfterMidnight` local time.
    func schedule(minutesAfterMidnight: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.requestID])

        let content = UNMutableNotificationContent()
        content.title = "Dry tonight?"
        content.body = "One tap. Your streak and your savings are waiting."
        content.sound = .default
        content.categoryIdentifier = Self.categoryID

        var components = DateComponents()
        components.hour = minutesAfterMidnight / 60
        components.minute = minutesAfterMidnight % 60
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        center.add(UNNotificationRequest(identifier: Self.requestID, content: content, trigger: trigger))
    }

    static func label(forMinutes minutes: Int) -> String {
        var components = DateComponents()
        components.hour = minutes / 60
        components.minute = minutes % 60
        let date = Calendar.current.date(from: components) ?? Date()
        return date.formatted(date: .omitted, time: .shortened)
    }
}

extension ReminderManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            didReceive response: UNNotificationResponse,
                                            withCompletionHandler completionHandler: @escaping () -> Void) {
        let action = response.actionIdentifier
        Task { @MainActor in
            switch action {
            case Self.dryActionID:
                onDryNight?()
            case Self.drankActionID, UNNotificationDefaultActionIdentifier:
                onDrank?()
            default:
                break
            }
            completionHandler()
        }
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification,
                                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
