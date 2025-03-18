import Foundation
import HealthKit
import SwiftData

enum Weekday: Int, CaseIterable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

/// The user settings.
@Model
final class AppSettings {
    /// Enable HealthKit integration.
    var enableHealthKit: Bool
    /// Write manual entries to HealthKit.
    var writeToHealthKit: Bool

    /// The start of the week for weekly statistics.
    var startOfWeek: Weekday

    /// The daily calorie budget.
    var dailyCalories: UInt
    /// The daily macro-nutrient breakdown.
    var dailyMacros: CalorieMacros

    init(
        enableHealthKit: Bool = false,
        writeToHealthKit: Bool = false,
        startOfWeek: Weekday = .monday,
        dailyCalories: UInt = 2500,
        dailyMacros: CalorieMacros = CalorieMacros()
    ) {
        self.enableHealthKit = enableHealthKit
        self.writeToHealthKit = writeToHealthKit

        self.dailyCalories = dailyCalories
        self.dailyMacros = dailyMacros
        self.startOfWeek = startOfWeek
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
