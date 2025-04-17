import Foundation
import SwiftData

/// A calorie macros breakdown.
struct CalorieMacros: Codable, Equatable {
    /// The protein breakdown.
    var protein: Double? = nil
    /// The fat breakdown.
    var fat: Double? = nil
    /// The carbs breakdown.
    var carbs: Double? = nil
}

/// Entry of consumed calories.
@Model final class ConsumedCalorie: DataRecord {
    var source = DataSource()

    /// The date the record was created.
    var date: Date
    /// The consumed calories.
    var calories: Double
    /// The calorie macros breakdown.
    var macros: CalorieMacros?

    init(_ calories: Double, macros: CalorieMacros? = nil, on date: Date) {
        self.date = date
        self.calories = calories
        self.macros = macros
    }
}

/// Entry of burned calories.
@Model final class BurnedCalorie: DataRecord {
    var source = DataSource()

    /// The date the record was created.
    var date: Date
    /// The burned calories.
    var calories: Double
    /// The duration of the activity.
    var duration: TimeInterval

    init(
        _ calories: Double, over duration: TimeInterval, on date: Date
    ) {
        self.date = date
        self.calories = calories
        self.duration = duration
    }
}
