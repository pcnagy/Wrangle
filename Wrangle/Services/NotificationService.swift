import UserNotifications
import Foundation

@MainActor
final class NotificationService {
    static let shared = NotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()
    private var hasPermission = false

    private init() {}

    func requestPermission() async -> Bool {
        do {
            hasPermission = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            return hasPermission
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    func scheduleNotification(for item: PlannerItem) async {
        if !hasPermission {
            guard await requestPermission() else { return }
        }
        guard let reminderMinutes = item.reminderMinutesBefore else { return }

        // Cancel existing notification for this item first
        cancelNotification(for: item)

        let content = UNMutableNotificationContent()
        content.title = "Upcoming: \(item.title)"
        content.body = "Starts in \(reminderMinutes) minutes"
        content.sound = .default
        content.categoryIdentifier = "PLANNER_ITEM"

        // Calculate trigger time
        let triggerDate = item.startTime.addingTimeInterval(-Double(reminderMinutes * 60))

        // Don't schedule if the trigger time is in the past
        guard triggerDate > Date() else { return }

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: notificationID(for: item),
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }

    func cancelNotification(for item: PlannerItem) {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [notificationID(for: item)]
        )
    }

    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    func getPendingNotifications() async -> [UNNotificationRequest] {
        await notificationCenter.pendingNotificationRequests()
    }

    private func notificationID(for item: PlannerItem) -> String {
        "wrangle-item-\(item.id)"
    }

    func setupNotificationCategories() {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_ACTION",
            title: "Mark Complete",
            options: []
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze 10 min",
            options: []
        )

        let category = UNNotificationCategory(
            identifier: "PLANNER_ITEM",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        notificationCenter.setNotificationCategories([category])
    }
}
