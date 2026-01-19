import SwiftUI
import SwiftData

struct ItemEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let item: PlannerItem?
    let selectedDate: Date

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var eventDate: Date = Date()
    @State private var startHour: Int = 9
    @State private var startMinute: Int = 0
    @State private var endHour: Int = 10
    @State private var endMinute: Int = 0
    @State private var priority: PlannerItem.Priority = .medium
    @State private var reminderEnabled: Bool = true
    @State private var reminderMinutes: Int = 15
    @State private var syncToCalendar: Bool = false
    @State private var selectedDuration: Int? = 60
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false

    private var isEditing: Bool { item != nil }

    private let durations: [(label: String, minutes: Int)] = [
        ("30m", 30),
        ("1h", 60),
        ("1.5h", 90),
        ("2h", 120),
        ("3h", 180)
    ]

    private var computedStartTime: Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: startHour,
                            minute: startMinute,
                            second: 0,
                            of: eventDate) ?? eventDate
    }

    private var computedEndTime: Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: endHour,
                            minute: endMinute,
                            second: 0,
                            of: eventDate) ?? eventDate
    }

    private var startTotalMinutes: Int {
        startHour * 60 + startMinute
    }

    private var endTotalMinutes: Int {
        endHour * 60 + endMinute
    }

    private var durationInMinutes: Int {
        endTotalMinutes - startTotalMinutes
    }

    private var durationText: String {
        let minutes = durationInMinutes
        if minutes <= 0 {
            return "Invalid"
        } else if minutes < 60 {
            return "\(minutes) min"
        } else if minutes % 60 == 0 {
            return "\(minutes / 60) hr"
        } else {
            return "\(minutes / 60) hr \(minutes % 60) min"
        }
    }

    private func formatHour(_ hour: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let period = hour < 12 ? "AM" : "PM"
        return "\(h) \(period)"
    }

    private func formatTimeDisplay(hour: Int, minute: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let period = hour < 12 ? "AM" : "PM"
        return String(format: "%d:%02d %@", h, minute, period)
    }

    private func updateEndTimeFromDuration(_ durationMinutes: Int) {
        let newEndMinutes = startTotalMinutes + durationMinutes
        endHour = min(23, newEndMinutes / 60)
        endMinute = newEndMinutes % 60
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: Theme.spacingL) {
                    // Title & Notes Section
                    VStack(alignment: .leading, spacing: Theme.spacingM) {
                        TextField("What's on your agenda?", text: $title)
                            .textFieldStyle(.plain)
                            .font(.system(.title2, design: .rounded, weight: .medium))
                            .foregroundStyle(Theme.textPrimary)

                        ZStack(alignment: .topLeading) {
                            if notes.isEmpty {
                                Text("Add notes...")
                                    .font(Theme.fontBody)
                                    .foregroundStyle(Theme.textTertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                            }
                            TextEditor(text: $notes)
                                .font(Theme.fontBody)
                                .foregroundStyle(Theme.textPrimary)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 60)
                        }
                        .padding(Theme.spacingM)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.radiusM)
                                .fill(Theme.backgroundSecondary.opacity(0.5))
                        )
                    }
                    .padding(Theme.spacingL)
                    .cardStyle()

                    // When Section
                    VStack(alignment: .leading, spacing: Theme.spacingM) {
                        // Date picker row
                        HStack {
                            Image(systemName: "calendar")
                                .font(.title3)
                                .foregroundStyle(Theme.accent)
                                .frame(width: 28)

                            DatePicker("", selection: $eventDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }

                        Divider()
                            .background(Theme.backgroundSecondary)

                        // Time picker row
                        HStack {
                            Image(systemName: "clock")
                                .font(.title3)
                                .foregroundStyle(Theme.accent)
                                .frame(width: 28)

                            // Start time button
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Start")
                                    .font(Theme.fontCaption)
                                    .foregroundStyle(Theme.textTertiary)

                                Button(action: { showStartTimePicker = true }) {
                                    Text(formatTimeDisplay(hour: startHour, minute: startMinute))
                                        .font(.system(.title3, design: .rounded, weight: .medium))
                                        .foregroundStyle(Theme.textPrimary)
                                        .padding(.horizontal, Theme.spacingM)
                                        .padding(.vertical, Theme.spacingS)
                                        .background(
                                            RoundedRectangle(cornerRadius: Theme.radiusS)
                                                .fill(Theme.backgroundSecondary)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Theme.radiusS)
                                                .stroke(showStartTimePicker ? Theme.accent : Color.clear, lineWidth: 2)
                                        )
                                }
                                .buttonStyle(.plain)
                                .popover(isPresented: $showStartTimePicker, arrowEdge: .bottom) {
                                    TimePickerPopover(hour: $startHour, minute: $startMinute, formatHour: formatHour)
                                }
                            }

                            Image(systemName: "arrow.right")
                                .font(.callout)
                                .foregroundStyle(Theme.textTertiary)
                                .padding(.horizontal, Theme.spacingS)

                            // End time button
                            VStack(alignment: .leading, spacing: 2) {
                                Text("End")
                                    .font(Theme.fontCaption)
                                    .foregroundStyle(Theme.textTertiary)

                                Button(action: { showEndTimePicker = true }) {
                                    Text(formatTimeDisplay(hour: endHour, minute: endMinute))
                                        .font(.system(.title3, design: .rounded, weight: .medium))
                                        .foregroundStyle(Theme.textPrimary)
                                        .padding(.horizontal, Theme.spacingM)
                                        .padding(.vertical, Theme.spacingS)
                                        .background(
                                            RoundedRectangle(cornerRadius: Theme.radiusS)
                                                .fill(Theme.backgroundSecondary)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Theme.radiusS)
                                                .stroke(showEndTimePicker ? Theme.accent : Color.clear, lineWidth: 2)
                                        )
                                }
                                .buttonStyle(.plain)
                                .popover(isPresented: $showEndTimePicker, arrowEdge: .bottom) {
                                    TimePickerPopover(hour: $endHour, minute: $endMinute, formatHour: formatHour)
                                }
                            }

                            Spacer()

                            // Duration badge
                            Text(durationText)
                                .font(Theme.fontCaption.weight(.medium))
                                .foregroundStyle(durationInMinutes > 0 ? Theme.accent : Theme.priorityHigh)
                                .padding(.horizontal, Theme.spacingM)
                                .padding(.vertical, Theme.spacingXS)
                                .background(
                                    Capsule()
                                        .fill(durationInMinutes > 0 ? Theme.accent.opacity(0.15) : Theme.priorityHigh.opacity(0.15))
                                )
                        }

                        // Duration quick buttons
                        HStack(spacing: Theme.spacingS) {
                            ForEach(durations, id: \.minutes) { duration in
                                Button(action: {
                                    selectedDuration = duration.minutes
                                    updateEndTimeFromDuration(duration.minutes)
                                }) {
                                    Text(duration.label)
                                        .font(Theme.fontCaption.weight(.medium))
                                        .foregroundStyle(selectedDuration == duration.minutes ? .white : Theme.textSecondary)
                                        .padding(.horizontal, Theme.spacingM)
                                        .padding(.vertical, Theme.spacingS)
                                        .background(
                                            Capsule()
                                                .fill(selectedDuration == duration.minutes ? Theme.accent : Theme.backgroundSecondary)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(Theme.spacingL)
                    .cardStyle()

                    // Priority Section
                    VStack(alignment: .leading, spacing: Theme.spacingM) {
                        HStack {
                            Image(systemName: "flag")
                                .font(.title3)
                                .foregroundStyle(Theme.accent)
                                .frame(width: 28)
                            Text("Priority")
                                .font(Theme.fontHeadline)
                                .foregroundStyle(Theme.textPrimary)
                        }

                        HStack(spacing: Theme.spacingS) {
                            ForEach(PlannerItem.Priority.allCases, id: \.self) { p in
                                Button(action: { priority = p }) {
                                    HStack(spacing: Theme.spacingS) {
                                        Circle()
                                            .fill(Theme.priorityColor(p))
                                            .frame(width: 10, height: 10)
                                        Text(p.label)
                                            .font(Theme.fontCallout.weight(.medium))
                                    }
                                    .padding(.horizontal, Theme.spacingL)
                                    .padding(.vertical, Theme.spacingM)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: Theme.radiusS)
                                            .fill(priority == p ? Theme.priorityColor(p).opacity(0.2) : Theme.backgroundSecondary)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.radiusS)
                                            .stroke(priority == p ? Theme.priorityColor(p) : Color.clear, lineWidth: 2)
                                    )
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(Theme.textPrimary)
                            }
                        }
                    }
                    .padding(Theme.spacingL)
                    .cardStyle()

                    // Options Section
                    VStack(alignment: .leading, spacing: Theme.spacingM) {
                        // Reminder toggle
                        HStack {
                            Image(systemName: "bell")
                                .font(.title3)
                                .foregroundStyle(Theme.accent)
                                .frame(width: 28)

                            Toggle(isOn: $reminderEnabled) {
                                Text("Reminder")
                                    .font(Theme.fontBody)
                                    .foregroundStyle(Theme.textPrimary)
                            }
                            .toggleStyle(.switch)
                            .tint(Theme.accent)
                        }

                        if reminderEnabled {
                            HStack(spacing: Theme.spacingS) {
                                ForEach([5, 15, 30, 60], id: \.self) { mins in
                                    Button(action: { reminderMinutes = mins }) {
                                        Text(mins < 60 ? "\(mins)m" : "1hr")
                                            .font(Theme.fontCaption.weight(.medium))
                                            .foregroundStyle(reminderMinutes == mins ? .white : Theme.textSecondary)
                                            .padding(.horizontal, Theme.spacingM)
                                            .padding(.vertical, Theme.spacingS)
                                            .background(
                                                Capsule()
                                                    .fill(reminderMinutes == mins ? Theme.accent : Theme.backgroundSecondary)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                                Text("before")
                                    .font(Theme.fontCaption)
                                    .foregroundStyle(Theme.textTertiary)
                            }
                            .padding(.leading, 36)
                        }

                        Divider()
                            .background(Theme.backgroundSecondary)

                        // Calendar sync toggle
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                                .font(.title3)
                                .foregroundStyle(Theme.accent)
                                .frame(width: 28)

                            Toggle(isOn: $syncToCalendar) {
                                Text("Sync to Calendar")
                                    .font(Theme.fontBody)
                                    .foregroundStyle(Theme.textPrimary)
                            }
                            .toggleStyle(.switch)
                            .tint(Theme.accent)
                        }
                    }
                    .padding(Theme.spacingL)
                    .cardStyle()

                    // Delete button (if editing)
                    if isEditing {
                        Button(action: deleteItem) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Item")
                            }
                            .font(Theme.fontCallout.weight(.medium))
                            .foregroundStyle(Theme.priorityHigh)
                            .frame(maxWidth: .infinity)
                            .padding(Theme.spacingM)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.radiusM)
                                    .fill(Theme.priorityHigh.opacity(0.1))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(Theme.spacingL)
            }
            .background(Theme.background)
        }
        .frame(minWidth: 420, minHeight: 580)
        .onAppear(perform: loadItem)
        .onChange(of: startHour) { _, _ in
            if let duration = selectedDuration {
                updateEndTimeFromDuration(duration)
            }
            updateDurationSelection()
        }
        .onChange(of: startMinute) { _, _ in
            if let duration = selectedDuration {
                updateEndTimeFromDuration(duration)
            }
            updateDurationSelection()
        }
        .onChange(of: endHour) { _, _ in
            updateDurationSelection()
        }
        .onChange(of: endMinute) { _, _ in
            updateDurationSelection()
        }
    }

    private func updateDurationSelection() {
        let currentDuration = durationInMinutes
        if durations.contains(where: { $0.minutes == currentDuration }) {
            selectedDuration = currentDuration
        } else {
            selectedDuration = nil
        }
    }

    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Text("Cancel")
                    .font(Theme.fontCallout)
                    .foregroundStyle(Theme.textSecondary)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.escape)

            Spacer()

            Text(isEditing ? "Edit Item" : "New Item")
                .font(Theme.fontHeadline)
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            Button(action: { saveItem() }) {
                Text("Save")
                    .font(Theme.fontCallout.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, Theme.spacingL)
                    .padding(.vertical, Theme.spacingS)
                    .background(
                        Capsule()
                            .fill(title.trimmingCharacters(in: .whitespaces).isEmpty ? Theme.textTertiary : Theme.accent)
                    )
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.return)
            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(Theme.spacingL)
        .background(Theme.cardBackground)
    }

    private func loadItem() {
        let calendar = Calendar.current

        if let item {
            title = item.title
            notes = item.notes
            eventDate = item.startTime
            startHour = calendar.component(.hour, from: item.startTime)
            startMinute = calendar.component(.minute, from: item.startTime)
            endHour = calendar.component(.hour, from: item.endTime)
            endMinute = calendar.component(.minute, from: item.endTime)
            priority = item.priority
            reminderEnabled = item.reminderMinutesBefore != nil
            reminderMinutes = item.reminderMinutesBefore ?? 15
            syncToCalendar = item.calendarEventID != nil

            // Check if duration matches a preset
            let durationMins = Int(item.endTime.timeIntervalSince(item.startTime) / 60)
            selectedDuration = durations.first { $0.minutes == durationMins }?.minutes
        } else {
            // Default times for new item
            let hour = calendar.component(.hour, from: Date())
            eventDate = selectedDate
            startHour = max(hour + 1, 9)
            startMinute = 0
            endHour = startHour + 1
            endMinute = 0
            selectedDuration = 60
        }
    }

    private func saveItem() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }

        let finalStartTime = computedStartTime
        let finalEndTime = computedEndTime

        if let item {
            // Update existing
            item.title = trimmedTitle
            item.notes = notes
            item.startTime = finalStartTime
            item.endTime = finalEndTime
            item.priority = priority
            item.reminderMinutesBefore = reminderEnabled ? reminderMinutes : nil
            item.updatedAt = Date()

            if syncToCalendar && item.calendarEventID == nil {
                Task {
                    await CalendarService.shared.createEvent(for: item)
                }
            }

            if reminderEnabled {
                Task {
                    await NotificationService.shared.scheduleNotification(for: item)
                }
            }
        } else {
            // Create new
            let newItem = PlannerItem(
                title: trimmedTitle,
                notes: notes,
                startTime: finalStartTime,
                endTime: finalEndTime,
                priority: priority,
                reminderMinutesBefore: reminderEnabled ? reminderMinutes : nil
            )
            modelContext.insert(newItem)

            if syncToCalendar {
                Task {
                    await CalendarService.shared.createEvent(for: newItem)
                }
            }

            if reminderEnabled {
                Task {
                    await NotificationService.shared.scheduleNotification(for: newItem)
                }
            }
        }

        dismiss()
    }

    private func deleteItem() {
        guard let item else { return }

        if let eventID = item.calendarEventID {
            Task {
                await CalendarService.shared.deleteEvent(withID: eventID)
            }
        }

        NotificationService.shared.cancelNotification(for: item)
        modelContext.delete(item)
        dismiss()
    }

    private func priorityColor(_ priority: PlannerItem.Priority) -> Color {
        Theme.priorityColor(priority)
    }
}

// MARK: - Time Picker Popover

struct TimePickerPopover: View {
    @Binding var hour: Int
    @Binding var minute: Int
    let formatHour: (Int) -> String

    private let hours = Array(0..<24)
    private let minutes = [0, 15, 30, 45]
    private let itemHeight: CGFloat = 48

    var body: some View {
        VStack(spacing: Theme.spacingL) {
            // Header
            Text("Select Time")
                .font(Theme.fontHeadline)
                .foregroundStyle(Theme.textSecondary)

            HStack(spacing: Theme.spacingM) {
                // Hour picker
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 4) {
                            ForEach(hours, id: \.self) { h in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        hour = h
                                    }
                                }) {
                                    Text(formatHour(h))
                                        .font(.system(.title3, design: .rounded, weight: hour == h ? .semibold : .regular))
                                        .foregroundStyle(hour == h ? .white : Theme.textPrimary)
                                        .frame(height: itemHeight)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: Theme.radiusS)
                                                .fill(hour == h ? Theme.accent : Color.clear)
                                        )
                                }
                                .buttonStyle(.plain)
                                .id(h)
                            }
                        }
                        .padding(Theme.spacingS)
                    }
                    .frame(width: 110, height: itemHeight * 5)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.radiusM)
                            .fill(Theme.backgroundSecondary)
                    )
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                proxy.scrollTo(hour, anchor: .center)
                            }
                        }
                    }
                }

                Text(":")
                    .font(.system(size: 36, weight: .light, design: .rounded))
                    .foregroundStyle(Theme.textTertiary)

                // Minute picker
                VStack(spacing: 4) {
                    ForEach(minutes, id: \.self) { m in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                minute = m
                            }
                        }) {
                            Text(String(format: "%02d", m))
                                .font(.system(.title3, design: .rounded, weight: minute == m ? .semibold : .regular))
                                .foregroundStyle(minute == m ? .white : Theme.textPrimary)
                                .frame(height: itemHeight)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.radiusS)
                                        .fill(minute == m ? Theme.accent : Color.clear)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(Theme.spacingS)
                .frame(width: 80)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusM)
                        .fill(Theme.backgroundSecondary)
                )
            }
        }
        .padding(Theme.spacingXL)
        .background(Theme.background)
    }
}

#Preview {
    ItemEditorView(item: nil, selectedDate: Date())
        .modelContainer(for: [PlannerItem.self, TimeBlock.self], inMemory: true)
}
