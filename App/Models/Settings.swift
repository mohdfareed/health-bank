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
    /// The active user daily calorie budget.
    static var dailyCalorieBudget: Settings<CalorieBudget.ID> {
        .init("DailyCalorieBudget", default: UUID())
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

/// A daily budget of calories and macro-nutrients.
@Model final class CalorieBudget: Singleton {
    typealias ID = UUID
    var id: UUID = UUID()
    init() {}

    var date: Date = Date()
    var calories: Double = 2000
    var macros: CalorieMacros? = CalorieMacros(
        p: 120, f: 60, c: 245
    )
}
