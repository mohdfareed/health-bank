import Foundation
import SwiftData
import SwiftUI

/// The app settings.
struct AppSettings {
    /// Whether to sync to HealthKit.
    static let healthKit = SettingsKey<Bool?>("HealthKit")
    /// Whether to enable biometrics for the app.
    static let biometrics = SettingsKey("Biometrics", default: false)
    /// Whether to enable notifications for the app.
    static let notifications = SettingsKey("Notifications", default: false)
    /// The active user daily calorie budget.
    static let dailyCalorieBudget = SettingsKey<PersistentIdentifier?>(
        "CalorieBudget", default: nil
    )
    init() {}
}

/// A daily budget of calories and macro-nutrients.
@Model final class CalorieBudget {
    /// The date the budget was set.
    var date: Date = Date()
    /// The daily calorie budget.
    var dailyCalories: Double? = 2000
    /// The daily protein budgets.
    var dailyProtein: Double? = 120
    /// The daily fat budget.
    var dailyFat: Double? = 60
    /// The daily carbs budget.
    var dailyCarbs: Double? = 245
    init() {}
}
