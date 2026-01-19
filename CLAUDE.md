# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Wrangle is a native macOS daily/weekly planner app built with SwiftUI. Features include Calendar.app sync, notifications, and menu bar access.

## Build Commands

Open in Xcode:
```bash
open Wrangle/
```

Then in Xcode: Product > Run (Cmd+R)

## Architecture

```
Wrangle/
├── WrangleApp.swift          # App entry point with MenuBarExtra
├── Models/
│   ├── PlannerItem.swift     # SwiftData model for tasks/events
│   └── TimeBlock.swift       # Time block definitions
├── Views/
│   ├── MainView.swift        # Primary navigation with sidebar
│   ├── DayView.swift         # Timeline view for single day
│   ├── WeekView.swift        # 7-day grid overview
│   ├── ItemEditorView.swift  # Create/edit planner items
│   └── MenuBarView.swift     # Menu bar popover
├── Services/
│   ├── CalendarService.swift     # EventKit integration
│   └── NotificationService.swift # UserNotifications
├── Info.plist                # App permissions
└── Wrangle.entitlements      # Sandbox entitlements
```

## Key Frameworks

- **SwiftData**: Local persistence for PlannerItem and TimeBlock models
- **EventKit**: Two-way Calendar.app sync
- **UserNotifications**: Reminder notifications
- **MenuBarExtra**: Menu bar widget

## Target

macOS 14+ (Sonoma) - uses latest SwiftUI and SwiftData APIs
