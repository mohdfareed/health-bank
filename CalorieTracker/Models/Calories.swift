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

    // TODO: Add optional protein, fat, and carbs properties

    init(_ calories: Int, on date: Date) {
        self.date = date
        self.calories = calories
    }
}

/// Calories budget cycle.
@Model
final class CalorieBudget {
    /// Display name of the budget.
    @Attribute(.unique) var name: String
    /// The amount of calories allowed per cycle.
    var calories: Int
    /// The number of days until the budget next resets.
    var period: Int
    /// The date when the budget started.
    var startDate: Date  // FIXME: Convert to reset day

    init(
        _ calories: Int,
        lasts period: Int,
        starting date: Date,
        named name: String
    ) {
        self.name = name
        self.calories = calories
        self.period = period
        self.startDate = date
    }
}
