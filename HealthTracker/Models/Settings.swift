import Foundation
import SwiftData

/// The app settings.
enum AppSettings {
    static let enableHealthKit = DefaultsKey(
        "\(Self.self).HealthKit", defaultValue: false
    )
    static let enableBiometrics = DefaultsKey(
        "\(Self.self).Biometrics", defaultValue: false
    )
    static let enableNotifications = DefaultsKey(
        "\(Self.self).Notifications", defaultValue: false
    )
}

/// A daily calories budget of the user.
@Model
final class DailyCaloriesBudgets: SingletonModel {
    /// The date the budget was set.
    var date: Date = Date()
    /// The daily calorie budget.
    var dailyCalories: UInt? = 2000
    /// The daily protein budgets.
    var dailyProtein: UInt? = 120
    /// The daily fat budget.
    var dailyFat: UInt? = 60
    /// The daily carbs budget.
    var dailyCarbs: UInt? = 245
    init() {}
}
