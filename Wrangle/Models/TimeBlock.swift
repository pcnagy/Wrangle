import Foundation
import SwiftData

@Model
final class TimeBlock {
    var name: String
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var color: String
    var isActive: Bool

    init(
        name: String,
        startHour: Int,
        startMinute: Int = 0,
        endHour: Int,
        endMinute: Int = 0,
        color: String = "blue",
        isActive: Bool = true
    ) {
        self.name = name
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.color = color
        self.isActive = isActive
    }

    var startTimeFormatted: String {
        String(format: "%d:%02d", startHour, startMinute)
    }

    var endTimeFormatted: String {
        String(format: "%d:%02d", endHour, endMinute)
    }

    var timeRange: String {
        "\(startTimeFormatted) - \(endTimeFormatted)"
    }

    static var defaults: [TimeBlock] {
        [
            TimeBlock(name: "Morning Routine", startHour: 6, endHour: 8, color: "yellow"),
            TimeBlock(name: "Deep Work", startHour: 8, endHour: 12, color: "purple"),
            TimeBlock(name: "Lunch", startHour: 12, endHour: 13, color: "green"),
            TimeBlock(name: "Meetings", startHour: 13, endHour: 15, color: "orange"),
            TimeBlock(name: "Afternoon Work", startHour: 15, endHour: 17, color: "blue"),
            TimeBlock(name: "Evening", startHour: 17, endHour: 21, color: "indigo")
        ]
    }
}
