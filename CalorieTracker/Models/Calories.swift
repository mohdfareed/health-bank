import Foundation
import SwiftData

/// Entry of calories consumed or burned.
@Model
final class CalorieEntry {
    /// The amount of calories.
    /// - Positive values represent calories consumed
    /// - Negative values represent calories burned
    var calories: Int
    /// The date the entry was created.
    var date: Date

    init(_ calories: Int, on date: Date) {
        self.date = date
        self.calories = calories
    }
}

/// Calories budget cycle.
@Model
final class CalorieBudget {
    /// Display name of the budget.
    var name: String?
    /// The amount of calories allowed per cycle.
    var budget: Int
    /// The number of days until the budget next resets.
    var period: Int
    /// The day the budget starts
    var startDay: Date

    init(_ budget: Int, lasts period: Int, starting date: Date? = nil, named name: String? = nil) {
        self.name = name
        self.budget = budget
        self.period = period
        self.startDay = date ?? Date.now

        // start budget cycle at midnight
        self.startDay = Calendar.current.startOfDay(for: self.startDay)
    }
}
