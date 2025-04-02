import Foundation
import SwiftData
import SwiftUI

/// The app settings.
struct AppSettings: Settings {
    /// Whether to sync to HealthKit.
    let healthKit: Bool? = nil
    /// Whether to enable biometrics for the app.
    var biometrics: Bool = false
    /// Whether to enable notifications for the app.
    var notifications: Bool = false
    /// The active user daily calorie budget.
    var caloriesBudget: PersistentIdentifier?
    init() {}
}

/// A daily calories budget of the user.
@Model final class CaloriesBudget: Settings {
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
