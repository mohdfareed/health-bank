import Foundation
import SwiftData
import SwiftUI

/// The app settings.
@MainActor struct AppSettings {
    @AppStorage("\(Self.self).HealthKit")
    var enableHealthKit: Bool?

    @AppStorage("\(Self.self).Biometrics")
    var enableBiometrics: Bool = false

    @AppStorage("\(Self.self).Notifications")
    var enableNotifications: Bool = false
}

/// A daily calories budget of the user.
@Model final class CaloriesBudgets: SingletonModel {
    var id = UUID()
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
