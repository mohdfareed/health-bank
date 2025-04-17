import Foundation
import SwiftData
import SwiftUI

/// The app color theme.
enum AppTheme: String, SettingsValue {
    case system, dark, light
}

/// The app settings. It is a collection of settings keys as static properties.
struct AppSettings {
    /// The app theme.
    static let theme = Settings<AppTheme>("AppTheme", default: .system)
    /// Whether to enable biometrics for the app. // TODO: Implement
    static let biometrics = Settings("Biometrics", default: false)
    /// Whether to enable notifications for the app. // TODO: Implement
    static let notifications = Settings<Bool?>("Notifications")

    // App Locale =============================================================

    /// The app's unit measurement system.
    static let unitSystem = Settings<Locale.MeasurementSystem?>(
        "MeasurementSystem", default: nil
    )
    /// The app's first day of the week.
    static let firstDayOfWeek = Settings<Locale.Weekday?>(
        "FirstWeekDay", default: nil
    )

    // User Settings ==========================================================

    /// The active user daily calorie budget.
    static let dailyCalorieBudget: Settings<CalorieBudget.ID?> = .init(
        "DailyCalorieBudget", default: nil
    )
}

/// A daily budget of calories and macro-nutrients.
@Model final class CalorieBudget: Singleton {
    typealias ID = UUID
    var id: UUID = UUID()
    init() {}

    /// The date the budget was set.
    var date: Date = Date()
    /// The daily calorie budget.
    var calories: Double? = 2000
    /// The daily calorie macros budgets.
    var macros: CalorieMacros = CalorieMacros(
        protein: 120, fat: 60, carbs: 245
    )
}
