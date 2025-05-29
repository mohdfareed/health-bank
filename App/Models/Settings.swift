import Foundation
import SwiftData

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

// Calorie Budget
extension Settings {
    /// The active user daily budgets.
    static var dailyBudgets: Settings<UUID> {
        .init("DailyBudgets", default: .init())
    }
    /// The active user daily goals.
    static var dailyGoals: Settings<UUID> {
        .init("DailyGoals", default: .init())
    }
}

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

/// The user's daily budgets.
@Model final class Budgets: Singleton {
    var date: Date = Date()
    var calories: Double? = 2000  // kcal
    var macros: CalorieMacros = CalorieMacros(
        p: 120, f: 60, c: 245  // grams
    )

    @Attribute(.unique)
    var id = UUID()
    init() {}
}

/// The user's daily goals.
@Model final class Goals: Singleton {
    var date: Date = Date()
    var weight: Double? = nil
    var activity: TimeInterval? = nil  // minutes
    var calories: Double? = nil  // burned

    @Attribute(.unique)
    var id = UUID()
    init() {}
}
