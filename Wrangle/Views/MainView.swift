import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDate = Date()
    @State private var viewMode: ViewMode = .day
    @State private var showingItemEditor = false
    @State private var selectedItem: PlannerItem?

    enum ViewMode: String, CaseIterable {
        case day = "Day"
        case week = "Week"
    }

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailView
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                toolbarItems
            }
        }
        .sheet(isPresented: $showingItemEditor) {
            ItemEditorView(item: selectedItem, selectedDate: selectedDate)
        }
    }

    private var sidebar: some View {
        VStack(spacing: 0) {
            // App title
            HStack {
                Text("Wrangle")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.accent)
                Spacer()
            }
            .padding(Theme.spacingL)

            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(Theme.accent)
                .padding(.horizontal)

            Divider()
                .padding(.vertical, Theme.spacingS)

            // View mode picker
            HStack(spacing: Theme.spacingS) {
                ForEach(ViewMode.allCases, id: \.self) { mode in
                    Button(action: { viewMode = mode }) {
                        Text(mode.rawValue)
                            .font(Theme.fontCallout.weight(.medium))
                            .foregroundStyle(viewMode == mode ? .white : .secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.spacingS)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.radiusS)
                                    .fill(viewMode == mode ? Theme.accent : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.spacingM)
            .padding(.vertical, Theme.spacingS)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(Theme.radiusM)
            .padding(.horizontal, Theme.spacingL)

            Spacer()

            // Today button
            Button(action: { navigateToToday() }) {
                HStack {
                    Image(systemName: "calendar.circle.fill")
                        .font(.title3)
                    Text("Today")
                        .font(Theme.fontCallout.weight(.medium))
                }
                .foregroundStyle(Theme.accent)
                .frame(maxWidth: .infinity)
                .padding(Theme.spacingM)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusM)
                        .fill(Theme.accent.opacity(0.1))
                )
            }
            .buttonStyle(.plain)
            .padding(Theme.spacingL)
        }
        .frame(minWidth: 260)
    }

    @ViewBuilder
    private var detailView: some View {
        switch viewMode {
        case .day:
            DayView(
                date: selectedDate,
                onItemTap: { item in
                    selectedItem = item
                    showingItemEditor = true
                },
                onAddItem: { date in
                    selectedItem = nil
                    selectedDate = date
                    showingItemEditor = true
                }
            )
        case .week:
            WeekView(
                startOfWeek: selectedDate.startOfWeek,
                onDaySelect: { date in
                    selectedDate = date
                    viewMode = .day
                }
            )
        }
    }

    @ViewBuilder
    private var toolbarItems: some View {
        Button(action: previousPeriod) {
            Image(systemName: "chevron.left")
                .font(.body.weight(.medium))
        }
        .help("Previous \(viewMode.rawValue)")

        Button(action: nextPeriod) {
            Image(systemName: "chevron.right")
                .font(.body.weight(.medium))
        }
        .help("Next \(viewMode.rawValue)")

        Button(action: {
            selectedItem = nil
            showingItemEditor = true
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.title3)
                .foregroundStyle(Theme.accent)
        }
        .help("Add Item")
    }

    private func navigateToToday() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedDate = Date()
        }
    }

    private func previousPeriod() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            switch viewMode {
            case .day:
                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            case .week:
                selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
            }
        }
    }

    private func nextPeriod() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            switch viewMode {
            case .day:
                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            case .week:
                selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
            }
        }
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) ?? self
    }

    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    var shortDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }

    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}

#Preview {
    MainView()
        .modelContainer(for: [PlannerItem.self, TimeBlock.self], inMemory: true)
}
