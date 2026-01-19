import SwiftUI
import SwiftData

struct DayView: View {
    let date: Date
    let onItemTap: (PlannerItem) -> Void
    let onAddItem: (Date) -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [PlannerItem]

    private let hourHeight: CGFloat = 64
    private let startHour = 6
    private let endHour = 22

    private var items: [PlannerItem] {
        let calendar = Calendar.current
        return allItems.filter { item in
            calendar.isDate(item.startTime, inSameDayAs: date)
        }.sorted { $0.startTime < $1.startTime }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                timelineView
            }
        }
        .background(Theme.background)
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(date.formatted(.dateTime.weekday(.wide)))
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(date.isToday ? Theme.accent : Theme.textPrimary)
                Text(date.formatted(.dateTime.month(.wide).day().year()))
                    .font(Theme.fontCallout)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()

            if !items.isEmpty {
                HStack(spacing: Theme.spacingXS) {
                    Text("\(items.count)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                    Text(items.count == 1 ? "item" : "items")
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

    private var timelineView: some View {
        ZStack(alignment: .topLeading) {
            // Hour grid
            VStack(spacing: 0) {
                ForEach(startHour..<endHour, id: \.self) { hour in
                    HStack(alignment: .top, spacing: Theme.spacingM) {
                        Text(formatHour(hour))
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(Theme.textTertiary)
                            .frame(width: 52, alignment: .trailing)

                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Theme.backgroundSecondary)
                                .frame(height: 1)
                            Spacer()
                        }
                    }
                    .frame(height: hourHeight)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let itemDate = dateForHour(hour)
                        onAddItem(itemDate)
                    }
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                }
            }

            // Current time indicator
            if date.isToday {
                currentTimeIndicator
            }

            // Items overlay
            itemsOverlay
        }
        .padding(.trailing, Theme.spacingL)
        .padding(.vertical, Theme.spacingM)
    }

    private var currentTimeIndicator: some View {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let minute = calendar.component(.minute, from: Date())

        let totalMinutes = (hour - startHour) * 60 + minute
        let yOffset = CGFloat(totalMinutes) * (hourHeight / 60)

        return HStack(spacing: 0) {
            Circle()
                .fill(Theme.accent)
                .frame(width: 10, height: 10)
            Rectangle()
                .fill(Theme.accent)
                .frame(height: 2)
        }
        .padding(.leading, 48)
        .offset(y: yOffset - 5)
        .opacity(hour >= startHour && hour < endHour ? 1 : 0)
    }

    private var itemsOverlay: some View {
        ForEach(items) { item in
            itemView(item)
        }
    }

    private func itemView(_ item: PlannerItem) -> some View {
        let calendar = Calendar.current
        let itemHour = calendar.component(.hour, from: item.startTime)
        let itemMinute = calendar.component(.minute, from: item.startTime)

        let startMinutes = (itemHour - startHour) * 60 + itemMinute
        let yOffset = CGFloat(startMinutes) * (hourHeight / 60)

        let durationMinutes = item.duration / 60
        let height = max(CGFloat(durationMinutes) * (hourHeight / 60), 36)

        let color = Theme.priorityColor(item.priority)

        return Button(action: { onItemTap(item) }) {
            HStack(spacing: Theme.spacingS) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: 4)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(.callout, design: .rounded, weight: .medium))
                        .foregroundStyle(item.isCompleted ? Theme.textTertiary : Theme.textPrimary)
                        .strikethrough(item.isCompleted)
                        .lineLimit(1)

                    if height > 44 {
                        Text(item.durationFormatted)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(Theme.textTertiary)
                    }
                }

                Spacer()

                if item.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.callout)
                        .foregroundStyle(Theme.success)
                }
            }
            .padding(.horizontal, Theme.spacingM)
            .padding(.vertical, Theme.spacingS)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusS)
                    .fill(color.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusS)
                    .stroke(color.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: color.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .padding(.leading, 70)
        .offset(y: yOffset)
    }

    private func formatHour(_ hour: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let period = hour < 12 ? "AM" : "PM"
        return "\(h) \(period)"
    }

    private func dateForHour(_ hour: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: date) ?? date
    }
}

#Preview {
    DayView(
        date: Date(),
        onItemTap: { _ in },
        onAddItem: { _ in }
    )
    .modelContainer(for: [PlannerItem.self, TimeBlock.self], inMemory: true)
}
