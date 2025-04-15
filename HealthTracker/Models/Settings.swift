import Foundation
import SwiftData
import SwiftUI

/// The app settings.
struct AppSettings {
    /// Whether to sync to HealthKit.
    static let healthKit = Settings<Bool?>("HealthKit")
    /// Whether to enable biometrics for the app.
    static let biometrics = Settings("Biometrics", default: false)
    /// Whether to enable notifications for the app.
    static let notifications = Settings("Notifications", default: false)
    /// The app's unit measurement system.
    static let unitSystem = Settings<Locale.MeasurementSystem?>(
        "MeasurementSystem", default: nil
    )
    /// The app's first day of the week.
    static let firstDayOfWeek = Settings<Locale.Weekday?>(
        "FirstWeekDay", default: nil
    )
    /// The active user daily calorie budget.
    static let dailyCalorieBudget: Settings<CalorieBudget.ID?> = .init(
        "CalorieBudget", default: nil
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
    var dailyCalories: Double? = 2000
    /// The daily calorie macros budgets.
    var dailyMacros: CalorieMacros = CalorieMacros(
        protein: 120, fat: 60, carbs: 245
    )
}
