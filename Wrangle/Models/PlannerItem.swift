import Foundation
import SwiftData

@Model
final class PlannerItem {
    var title: String
    var notes: String
    var startTime: Date
    var endTime: Date
    var isCompleted: Bool
    var priority: Priority
    var calendarEventID: String?
    var reminderMinutesBefore: Int?
    var createdAt: Date
    var updatedAt: Date

    enum Priority: Int, Codable, CaseIterable {
        case low = 0
        case medium = 1
        case high = 2

        var label: String {
            switch self {
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            }
        }

        var color: String {
            switch self {
            case .low: return "blue"
            case .medium: return "orange"
            case .high: return "red"
            }
        }
    }

    init(
        title: String,
        notes: String = "",
        startTime: Date,
        endTime: Date,
        isCompleted: Bool = false,
        priority: Priority = .medium,
        calendarEventID: String? = nil,
        reminderMinutesBefore: Int? = 15
    ) {
        self.title = title
        self.notes = notes
        self.startTime = startTime
        self.endTime = endTime
        self.isCompleted = isCompleted
        self.priority = priority
        self.calendarEventID = calendarEventID
        self.reminderMinutesBefore = reminderMinutesBefore
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
