import Foundation
import SwiftData
import SwiftUI

/// The app settings.
@MainActor enum AppSettings {
    /// Whether to read from and sync to HealthKit.
    @Settings(Self.self, "HealthKit")
    static var enableHealthKit: SettingsKey<Bool?>

    /// Whether to enable biometrics for the app.
    @Settings(Self.self, "Biometrics", default: false)
    static var enableBiometrics: SettingsKey<Bool>

    /// Whether to enable notifications for the app.
    @Settings(Self.self, "Notifications", default: false)
    static var enableNotifications: SettingsKey<Bool>

    /// The active user daily calorie budget.
    @Settings(Self.self, "CaloriesBudget")
    static var caloriesBudget: SettingsKey<PersistentIdentifier?>
}

/// A daily calories budget of the user.
@Model final class CaloriesBudget {
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
