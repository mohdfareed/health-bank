import Foundation
import HealthKit
import SwiftData

/// The app's start of the week.
enum Weekday: Int, CaseIterable, Codable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

/// A daily budgets configuration.
struct DailyBudgets: Codable {
    /// The daily calorie budget.
    var dailyCalories: UInt = 2000
    /// The daily macros budgets.
    var dailyMacros = CalorieMacros(
        protein: 120, fat: 60, carbs: 245
    )
}

// MARK: App Settings

/// The user settings.
@Model
final class AppSettings: SingletonModel {
    static var singletonFactory: () -> AppSettings = { .init() }

    /// The start of the week for weekly statistics.
    var startOfWeek: Weekday
    /// The user's daily budgets.
    var budgets: DailyBudgets
    /// Enable HealthKit integration.
    var enableHealthKit: Bool

    init(
        startOfWeek: Weekday = .sunday,
        budgets: DailyBudgets = DailyBudgets(),
        enableHealthKit: Bool = false
    ) {
        self.enableHealthKit = enableHealthKit
        self.budgets = budgets
    }

    convenience init() {
        self.init(enableHealthKit: false)
    }
}

/// App state and user choices.
@Model
final class AppState: SingletonModel {
    static var singletonFactory: () -> AppState = { .init() }

    /// Whether the user has responded to `Settings.enableHealthKit`.
    var hasRespondedToEnableHealthKit: Bool

    init(hasRespondedToEnableHealthKit: Bool = false) {
        self.hasRespondedToEnableHealthKit = hasRespondedToEnableHealthKit
    }

    convenience init() {
        self.init(hasRespondedToEnableHealthKit: false)
    }
}
