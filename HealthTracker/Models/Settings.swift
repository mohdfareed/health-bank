import Foundation
import HealthKit
import SwiftData

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
    /// The start of the week for weekly statistics.
    var startOfWeek: Weekday = .sunday
    /// The daily calorie budget.
    var dailyCalories: UInt = 2000
    /// The daily macros budgets.
    var dailyMacros: CalorieMacros

    init(
        startOfWeek: Weekday = .sunday,
        dailyCalories: UInt = 2000,
        dailyMacros: CalorieMacros = CalorieMacros(protein: 120, fat: 60, carbs: 245)
    ) {
        self.startOfWeek = startOfWeek
        self.dailyCalories = dailyCalories
        self.dailyMacros = dailyMacros
    }
}

/// The user settings.
@Model
final class AppSettings {
    /// Enable HealthKit integration.
    var enableHealthKit: Bool
    /// Write manual entries to HealthKit.
    var writeToHealthKit: Bool
    /// The user's daily budgets.
    var budgets: DailyBudgets

    init(
        enableHealthKit: Bool = false,
        writeToHealthKit: Bool = false,
        budgets: DailyBudgets = DailyBudgets()
    ) {
        self.enableHealthKit = enableHealthKit
        self.writeToHealthKit = writeToHealthKit
        self.budgets = budgets
    }
}

/// App state and user choices.
@Model
final class AppState {
    /// Whether the user has responded to `Settings.enableHealthKit`.
    var hasRespondedToEnableHealthKit: Bool
    /// Whether the user has responded to `Settings.writeToHealthKit`.
    var hasRespondedToWriteToHealthKit: Bool

    init(
        hasRespondedToEnableHealthKit: Bool = false,
        hasRespondedToWriteToHealthKit: Bool = false
    ) {
        self.hasRespondedToEnableHealthKit = hasRespondedToEnableHealthKit
        self.hasRespondedToWriteToHealthKit = hasRespondedToWriteToHealthKit
    }
}
