import EventKit
import Foundation

@MainActor
final class CalendarService {
    static let shared = CalendarService()

    private let eventStore = EKEventStore()
    private var hasAccess = false

    private init() {}

    func requestAccess() async -> Bool {
        do {
            if #available(macOS 14.0, *) {
                hasAccess = try await eventStore.requestFullAccessToEvents()
            } else {
                hasAccess = try await eventStore.requestAccess(to: .event)
            }
            return hasAccess
        } catch {
            print("Calendar access error: \(error)")
            return false
        }
    }

    func checkAccessStatus() -> EKAuthorizationStatus {
        if #available(macOS 14.0, *) {
            return EKEventStore.authorizationStatus(for: .event)
        } else {
            return EKEventStore.authorizationStatus(for: .event)
        }
    }

    func fetchEvents(for date: Date) async -> [EKEvent] {
        if !hasAccess {
            guard await requestAccess() else { return [] }
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date

        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )

        return eventStore.events(matching: predicate)
    }

    func fetchEvents(from startDate: Date, to endDate: Date) async -> [EKEvent] {
        if !hasAccess {
            guard await requestAccess() else { return [] }
        }

        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil
        )

        return eventStore.events(matching: predicate)
    }

    func createEvent(for item: PlannerItem) async -> String? {
        if !hasAccess {
            guard await requestAccess() else { return nil }
        }

        let event = EKEvent(eventStore: eventStore)
        event.title = item.title
        event.notes = item.notes
        event.startDate = item.startTime
        event.endDate = item.endTime
        event.calendar = eventStore.defaultCalendarForNewEvents

        do {
            try eventStore.save(event, span: .thisEvent)
            item.calendarEventID = event.eventIdentifier
            return event.eventIdentifier
        } catch {
            print("Failed to create calendar event: \(error)")
            return nil
        }
    }

    func updateEvent(for item: PlannerItem) async -> Bool {
        if !hasAccess {
            guard await requestAccess() else { return false }
        }
        guard let eventID = item.calendarEventID,
              let event = eventStore.event(withIdentifier: eventID) else {
            return false
        }

        event.title = item.title
        event.notes = item.notes
        event.startDate = item.startTime
        event.endDate = item.endTime

        do {
            try eventStore.save(event, span: .thisEvent)
            return true
        } catch {
            print("Failed to update calendar event: \(error)")
            return false
        }
    }

    func deleteEvent(withID eventID: String) async -> Bool {
        if !hasAccess {
            guard await requestAccess() else { return false }
        }
        guard let event = eventStore.event(withIdentifier: eventID) else {
            return false
        }

        do {
            try eventStore.remove(event, span: .thisEvent)
            return true
        } catch {
            print("Failed to delete calendar event: \(error)")
            return false
        }
    }

    func getCalendars() -> [EKCalendar] {
        eventStore.calendars(for: .event)
    }
}
