import SwiftUI
import SwiftData

struct MenuBarView: View {
    let openMainWindow: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [PlannerItem]

    @State private var showingQuickAdd = false
    @State private var quickAddTitle = ""

    private var todayItems: [PlannerItem] {
        let calendar = Calendar.current
        return allItems.filter { item in
            calendar.isDateInToday(item.startTime)
        }.sorted { $0.startTime < $1.startTime }
    }

    private var upcomingItem: PlannerItem? {
        todayItems.first { !$0.isCompleted && $0.startTime > Date() }
    }

    private var completedCount: Int {
        todayItems.filter(\.isCompleted).count
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if showingQuickAdd {
                quickAddSection
            } else {
                todaySection
            }

            footer
        }
        .frame(width: 320)
        .background(Theme.cardBackground)
    }

    private var header: some View {
        VStack(spacing: Theme.spacingM) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                        .font(Theme.fontCaption)
                        .foregroundStyle(Theme.textTertiary)
                }

                Spacer()

                if !todayItems.isEmpty {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(completedCount)/\(todayItems.count)")
                            .font(.system(.callout, design: .rounded, weight: .semibold))
                            .foregroundStyle(completedCount == todayItems.count ? Theme.success : Theme.accent)
                        Text("done")
                            .font(Theme.fontCaption)
                            .foregroundStyle(Theme.textTertiary)
                    }
                }
            }

            if let upcoming = upcomingItem {
                HStack(spacing: Theme.spacingS) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundStyle(Theme.accent)

                    Text("Next: \(upcoming.title)")
                        .font(Theme.fontCaption)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)

                    Spacer()

                    Text(upcoming.startTime.formatted(.dateTime.hour().minute()))
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(Theme.accent)
                }
                .padding(Theme.spacingS)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusS)
                        .fill(Theme.accent.opacity(0.1))
                )
            }
        }
        .padding(Theme.spacingL)
        .background(Theme.background)
    }

    private var todaySection: some View {
        ScrollView {
            LazyVStack(spacing: Theme.spacingS) {
                if todayItems.isEmpty {
                    VStack(spacing: Theme.spacingM) {
                        Image(systemName: "sun.max")
                            .font(.system(size: 36))
                            .foregroundStyle(Theme.accent.opacity(0.5))
                        Text("Your day is clear!")
                            .font(Theme.fontCallout)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingXXL)
                } else {
                    ForEach(todayItems) { item in
                        menuBarItemRow(item)
                    }
                }
            }
            .padding(.horizontal, Theme.spacingL)
            .padding(.vertical, Theme.spacingM)
        }
        .frame(maxHeight: 260)
    }

    private func menuBarItemRow(_ item: PlannerItem) -> some View {
        HStack(spacing: Theme.spacingM) {
            Button(action: { toggleCompleted(item) }) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(item.isCompleted ? Theme.success : Theme.textTertiary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(.callout, design: .rounded, weight: .medium))
                    .strikethrough(item.isCompleted)
                    .foregroundStyle(item.isCompleted ? Theme.textTertiary : Theme.textPrimary)

                Text(timeRange(for: item))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Theme.textTertiary)
            }

            Spacer()

            Circle()
                .fill(Theme.priorityColor(item.priority))
                .frame(width: 8, height: 8)
        }
        .padding(Theme.spacingM)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusS)
                .fill(item.isCompleted ? Color.clear : Theme.backgroundSecondary.opacity(0.5))
        )
    }

    private var quickAddSection: some View {
        VStack(spacing: Theme.spacingM) {
            TextField("What's on your mind?", text: $quickAddTitle)
                .textFieldStyle(.plain)
                .font(Theme.fontBody)
                .padding(Theme.spacingM)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusS)
                        .fill(Theme.backgroundSecondary)
                )
                .onSubmit(submitQuickAdd)

            HStack {
                Button(action: {
                    quickAddTitle = ""
                    showingQuickAdd = false
                }) {
                    Text("Cancel")
                        .font(Theme.fontCaption)
                        .foregroundStyle(Theme.textSecondary)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.escape)

                Spacer()

                Button(action: submitQuickAdd) {
                    Text("Add")
                        .font(Theme.fontCaption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, Theme.spacingL)
                        .padding(.vertical, Theme.spacingS)
                        .background(
                            Capsule()
                                .fill(quickAddTitle.trimmingCharacters(in: .whitespaces).isEmpty ? Theme.textTertiary : Theme.accent)
                        )
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.return)
                .disabled(quickAddTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(Theme.spacingL)
    }

    private var footer: some View {
        HStack {
            Button(action: { showingQuickAdd.toggle() }) {
                HStack(spacing: Theme.spacingXS) {
                    Image(systemName: showingQuickAdd ? "xmark" : "plus.circle.fill")
                        .font(.callout)
                    Text(showingQuickAdd ? "Cancel" : "Quick Add")
                        .font(Theme.fontCaption.weight(.medium))
                }
                .foregroundStyle(showingQuickAdd ? Theme.textSecondary : Theme.accent)
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: openMainWindow) {
                HStack(spacing: Theme.spacingXS) {
                    Text("Open Wrangle")
                        .font(Theme.fontCaption.weight(.medium))
                    Image(systemName: "arrow.up.forward")
                        .font(.caption2)
                }
                .foregroundStyle(Theme.textSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(Theme.spacingL)
        .background(Theme.background)
    }

    private func toggleCompleted(_ item: PlannerItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            item.isCompleted.toggle()
            item.updatedAt = Date()
        }
    }

    private func submitQuickAdd() {
        let trimmed = quickAddTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let calendar = Calendar.current
        let now = Date()
        let startHour = calendar.component(.hour, from: now)
        let startTime = calendar.date(bySettingHour: max(startHour + 1, 8), minute: 0, second: 0, of: now) ?? now
        let endTime = calendar.date(byAdding: .hour, value: 1, to: startTime) ?? startTime

        let newItem = PlannerItem(
            title: trimmed,
            startTime: startTime,
            endTime: endTime
        )
        modelContext.insert(newItem)

        quickAddTitle = ""
        showingQuickAdd = false
    }

    private func timeRange(for item: PlannerItem) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return "\(formatter.string(from: item.startTime)) - \(formatter.string(from: item.endTime))"
    }
}

#Preview {
    MenuBarView(openMainWindow: {})
        .modelContainer(for: [PlannerItem.self, TimeBlock.self], inMemory: true)
}
