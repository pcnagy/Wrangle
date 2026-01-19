import SwiftUI
import SwiftData

struct WeekView: View {
    let startOfWeek: Date
    let onDaySelect: (Date) -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [PlannerItem]

    private var weekDays: [Date] {
        (0..<7).compactMap { dayOffset in
            Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Theme.spacingM), count: 7), spacing: Theme.spacingM) {
                    ForEach(weekDays, id: \.self) { day in
                        dayCard(for: day)
                    }
                }
                .padding(Theme.spacingL)
            }
        }
        .background(Theme.background)
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(weekRangeString)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Text("Week \(weekNumber)")
                    .font(Theme.fontCallout)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()

            // Total items this week
            let totalItems = weekDays.flatMap { itemsForDate($0) }.count
            if totalItems > 0 {
                HStack(spacing: Theme.spacingXS) {
                    Text("\(totalItems)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                    Text("this week")
                        .font(Theme.fontCaption)
                        .foregroundStyle(Theme.textTertiary)
                }
                .padding(.horizontal, Theme.spacingM)
                .padding(.vertical, Theme.spacingS)
                .background(
                    Capsule()
                        .fill(Theme.accent.opacity(0.1))
                )
            }
        }
        .padding(Theme.spacingL)
        .background(Theme.cardBackground)
    }

    private var weekRangeString: String {
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek) ?? startOfWeek
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }

    private var weekNumber: Int {
        Calendar.current.component(.weekOfYear, from: startOfWeek)
    }

    private func dayCard(for date: Date) -> some View {
        let dayItems = itemsForDate(date)

        return Button(action: { onDaySelect(date) }) {
            VStack(spacing: Theme.spacingS) {
                // Day header
                VStack(spacing: 2) {
                    Text(date.shortDayName)
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(Theme.textTertiary)
                    Text(date.dayNumber)
                        .font(.system(.title2, design: .rounded, weight: date.isToday ? .bold : .medium))
                        .foregroundStyle(date.isToday ? .white : Theme.textPrimary)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(date.isToday ? Theme.accent : Color.clear)
                        )
                }

                Rectangle()
                    .fill(Theme.backgroundSecondary)
                    .frame(height: 1)

                // Items summary
                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                    if dayItems.isEmpty {
                        Spacer()
                        Text("Free")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(Theme.textTertiary)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                    } else {
                        ForEach(dayItems.prefix(3)) { item in
                            itemRow(item)
                        }

                        if dayItems.count > 3 {
                            Text("+\(dayItems.count - 3) more")
                                .font(.system(.caption2, design: .rounded, weight: .medium))
                                .foregroundStyle(Theme.textTertiary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                // Completion indicator
                if !dayItems.isEmpty {
                    completionIndicator(for: dayItems)
                }
            }
            .padding(Theme.spacingM)
            .frame(minHeight: 200)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .fill(Theme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .stroke(date.isToday ? Theme.accent : Theme.backgroundSecondary, lineWidth: date.isToday ? 2 : 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func itemRow(_ item: PlannerItem) -> some View {
        HStack(spacing: Theme.spacingXS) {
            Circle()
                .fill(Theme.priorityColor(item.priority))
                .frame(width: 6, height: 6)

            Text(item.title)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(item.isCompleted ? Theme.textTertiary : Theme.textPrimary)
                .strikethrough(item.isCompleted)
                .lineLimit(1)

            Spacer()

            if item.isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(.caption2, weight: .bold))
                    .foregroundStyle(Theme.success)
            }
        }
    }

    private func completionIndicator(for items: [PlannerItem]) -> some View {
        let completed = items.filter(\.isCompleted).count
        let total = items.count
        let progress = Double(completed) / Double(total)

        return HStack(spacing: Theme.spacingXS) {
            // Custom progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.backgroundSecondary)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(progress == 1 ? Theme.success : Theme.accent)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 4)

            Text("\(completed)/\(total)")
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(Theme.textTertiary)
        }
    }

    private func itemsForDate(_ date: Date) -> [PlannerItem] {
        let calendar = Calendar.current
        return allItems.filter { item in
            calendar.isDate(item.startTime, inSameDayAs: date)
        }.sorted { $0.startTime < $1.startTime }
    }
}

#Preview {
    WeekView(
        startOfWeek: Date().startOfWeek,
        onDaySelect: { _ in }
    )
    .modelContainer(for: [PlannerItem.self, TimeBlock.self], inMemory: true)
}
