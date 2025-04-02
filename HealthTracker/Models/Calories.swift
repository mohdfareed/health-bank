import Foundation
import SwiftData

/// Entry of consumed calories.
@Model final class CaloriesConsumed: DataResource {
    var source: DataSource
    /// The date the record was created.
    var date: Date
    /// The consumed calories.
    var calories: Double

    init(_ calories: Double, on date: Date, from source: DataSource) {
        self.source = source
        self.date = date
        self.calories = calories
    }
}

/// Entry of burned calories.
@Model final class CaloriesBurned: DataResource {
    var source: DataSource
    /// The date the record was created.
    var date: Date
    /// The burned calories.
    var calories: Double
    /// The duration of the activity.
    var duration: TimeInterval

    init(
        _ calories: Double, over duration: TimeInterval,
        on date: Date, from source: DataSource
    ) {
        self.source = source
        self.date = date
        self.calories = calories
        self.duration = duration
    }
}
