import Foundation
import SwiftData
import SwiftUI

// MARK: App Settings
// ============================================================================

/// The app color theme.
enum AppTheme: String, SettingsValue {
    case system, dark, light
}

/// The app settings as a static collection of keys.
struct AppSettings {
    /// The app theme.
    static let theme = Settings<AppTheme>("AppTheme", default: .system)
    /// Whether to enable biometrics for the app. // TODO: Implement
    static let biometrics = Settings("Biometrics", default: false)
    /// Whether to enable notifications for the app. // TODO: Implement
    static let notifications = Settings<Bool?>("Notifications")
}

// App Locale
extension AppSettings {
    /// The app's unit measurement system.
    static let unitSystem = Settings<Locale.MeasurementSystem?>(
        "MeasurementSystem", default: nil
    )
    /// The app's first day of the week.
    static let firstDayOfWeek = Settings<Locale.Weekday?>(
        "FirstWeekDay", default: nil
    )
}

// Calorie Budget
extension AppSettings {
    /// The active user daily calorie budget.
    static let dailyCalorieBudget: Settings<CalorieBudget.ID> = .init(
        "DailyCalorieBudget", default: UUID()
    )
}

// MARK: App Units
// ============================================================================

extension UnitDefinition {
    /// The unit for calories consumed.
    static var calorieUnit: UnitDefinition<UnitEnergy> {
        .init(usage: .food)
    }

    /// The unit for a calorie macros breakdown.
    static var macrosUnit: UnitDefinition<UnitMass> {
        .init(unit: .grams)
    }

    /// The unit for a workout duration.
    static var workoutUnit: UnitDefinition<UnitDuration> {
        .init(alternatives: [.minutes, .hours])
    }
}
