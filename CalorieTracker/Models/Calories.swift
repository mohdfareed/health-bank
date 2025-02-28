import Foundation
import SwiftData

/// Entry of calories consumed or burned.
@Model
final class CalorieEntry {

    /// Data sources.
    enum DataSource: String, Codable, CaseIterable {
        case manual, healthKit
    }

    /// The amount of calories.
    /// - Positive values represent calories consumed
    /// - Negative values represent calories burned
    var calories: Int
    /// The date the entry was created.
    var date: Date
    /// The data source of the entry.
    var source: DataSource

    init(calories: Int, date: Date, source: DataSource) {
        self.date = date
        self.calories = calories
        self.source = source
    }
}

/// Calories weekly budget cycle.
@Model
final class WeeklyBudget {

    /// Days of the week.
    enum WeekDay: Int, CaseIterable {
        case sunday = 1
        case monday, tuesday, wednesday, thursday, friday, saturday
    }

    /// The amount of calories allowed per cycle.
    var budget: Int
    /// The day of the week on which the budget resets.
    var resetDay: WeekDay
    /// The number of weeks the budget lasts.
    var duration: Int = 1

    init(budget: Int, resetDay: WeekDay, duration: Int = 1) {
        self.budget = budget
        self.resetDay = resetDay
        self.duration = duration
    }
}
