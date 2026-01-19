import SwiftUI
import SwiftData

@main
struct WrangleApp: App {
    let container: ModelContainer

    @State private var showingMainWindow = true

    init() {
        do {
            container = try ModelContainer(for: PlannerItem.self, TimeBlock.self)
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(container)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 900, height: 600)

        MenuBarExtra("Wrangle", systemImage: "calendar.badge.clock") {
            MenuBarView(openMainWindow: openMainWindow)
                .modelContainer(container)
        }
        .menuBarExtraStyle(.window)
    }

    private func openMainWindow() {
        if let window = NSApplication.shared.windows.first(where: { $0.title.contains("Wrangle") || $0.contentView is NSHostingView<MainView> }) {
            window.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
        } else {
            NSWorkspace.shared.open(URL(string: "wrangle://open")!)
        }
    }
}
