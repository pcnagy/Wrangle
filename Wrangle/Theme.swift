import SwiftUI

// MARK: - Wrangle Theme
// Warm & Cozy design system

enum Theme {
    // MARK: - Colors

    // Primary warm accent
    static let accent = Color(red: 0.91, green: 0.45, blue: 0.32) // Warm coral
    static let accentLight = Color(red: 0.95, green: 0.65, blue: 0.55)
    static let accentDark = Color(red: 0.75, green: 0.35, blue: 0.25)

    // Backgrounds
    static let background = Color(red: 0.98, green: 0.96, blue: 0.94) // Warm cream
    static let backgroundSecondary = Color(red: 0.95, green: 0.92, blue: 0.88)
    static let cardBackground = Color.white

    // Text
    static let textPrimary = Color(red: 0.2, green: 0.18, blue: 0.16)
    static let textSecondary = Color(red: 0.45, green: 0.42, blue: 0.38)
    static let textTertiary = Color(red: 0.65, green: 0.62, blue: 0.58)

    // Priority colors (warmer versions)
    static let priorityLow = Color(red: 0.4, green: 0.65, blue: 0.75) // Soft teal
    static let priorityMedium = Color(red: 0.92, green: 0.7, blue: 0.4) // Warm amber
    static let priorityHigh = Color(red: 0.85, green: 0.45, blue: 0.45) // Soft red

    // Status colors
    static let success = Color(red: 0.55, green: 0.75, blue: 0.55) // Soft green
    static let warning = Color(red: 0.92, green: 0.75, blue: 0.45)

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 24
    static let spacingXXL: CGFloat = 32

    // MARK: - Corner Radius

    static let radiusS: CGFloat = 8
    static let radiusM: CGFloat = 12
    static let radiusL: CGFloat = 16
    static let radiusXL: CGFloat = 20

    // MARK: - Shadows

    static func softShadow() -> some View {
        Color.black.opacity(0.06)
    }

    // MARK: - Fonts

    static let fontTitle = Font.system(.title, design: .rounded, weight: .semibold)
    static let fontHeadline = Font.system(.headline, design: .rounded, weight: .semibold)
    static let fontBody = Font.system(.body, design: .rounded)
    static let fontCallout = Font.system(.callout, design: .rounded)
    static let fontCaption = Font.system(.caption, design: .rounded)

    // MARK: - Priority Helper

    static func priorityColor(_ priority: PlannerItem.Priority) -> Color {
        switch priority {
        case .low: return priorityLow
        case .medium: return priorityMedium
        case .high: return priorityHigh
        }
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .fill(Theme.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
    }

    func softCardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .fill(Theme.backgroundSecondary.opacity(0.6))
            )
    }

    func pillButtonStyle(isSelected: Bool) -> some View {
        self
            .padding(.horizontal, Theme.spacingM)
            .padding(.vertical, Theme.spacingS)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusS)
                    .fill(isSelected ? Theme.accent : Theme.backgroundSecondary)
            )
            .foregroundStyle(isSelected ? .white : Theme.textPrimary)
    }
}

// MARK: - Custom Button Styles

struct WarmButtonStyle: ButtonStyle {
    var isPrimary: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.fontCallout.weight(.medium))
            .padding(.horizontal, Theme.spacingL)
            .padding(.vertical, Theme.spacingS)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusS)
                    .fill(isPrimary ? Theme.accent : Theme.backgroundSecondary)
            )
            .foregroundStyle(isPrimary ? .white : Theme.textPrimary)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.fontCallout)
            .foregroundStyle(Theme.textSecondary)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}
