import Foundation
import SwiftData

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
    /// Whether to enable biometrics for the app. // TODO: Implement
    static var biometrics: Settings<Bool?> { .init("Biometrics") }
    /// Whether to enable notifications for the app. // TODO: Implement
    static var notifications: Settings<Bool?> { .init("Notifications") }
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
        .init("Goals", default: .init())
    }
}

// MARK: Trackers
// ============================================================================

/// The user's daily goals.
@Model final class UserGoals: Singleton {
    var date: Date = Date()

    // calories
    var calories: Double? = 2000  // consumed
    var macros: CalorieMacros = CalorieMacros(
        p: 120, f: 60, c: 245  // grams
    )

    // activity
    var burnedCalories: Double? = 350  // burned
    var activity: TimeInterval? = 30  // minutes

    // weight
    var weight: Double? = 70  // kg

    // singleton
    @Attribute(.unique)
    var singletonID = UUID()
    required init() {}
}
