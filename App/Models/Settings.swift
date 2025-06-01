import Foundation

// MARK: Definitions
// ============================================================================

/// The app color theme.
enum AppTheme: String, SettingsValue, CaseIterable {
    case system, dark, light
}

/// The app's measurement system.
typealias MeasurementSystem = Locale.MeasurementSystem
/// The app's first day of the week.
typealias Weekday = Locale.Weekday

// MARK: Settings
// ============================================================================

/// The app settings as a static collection of keys.
extension Settings {
    /// The app theme.
    static var theme: Settings<AppTheme> { .init("Theme", default: .system) }
    /// Whether to enable biometrics for the app.
    static var biometrics: Settings<Bool?> { .init("Biometrics") }
    /// Whether to enable notifications for the app.
    static var notifications: Settings<Bool?> { .init("Notifications") }
    /// Whether to enable HealthKit integration.
    static var enableHealthKit: Settings<Bool> {
        .init("EnableHealthKit", default: true)
    }
}

// Localization
extension Settings {
    /// The app's unit measurement system.
    static var unitSystem: Settings<MeasurementSystem?> {
        .init("MeasurementSystem", default: nil)
    }
    /// The app's first day of the week.
    static var firstDayOfWeek: Settings<Weekday?> {
        .init("FirstWeekDay", default: nil)
    }
}

// Trackers
extension Settings {
    /// The active user daily goals.
    static var userGoals: Settings<UUID> {
        .init("Goals", default: .zero)
    }
}
