import Foundation
import SwiftData

/// Entry of consumed calories.
@Model
final class CaloriesConsumed: DataModel {
    var source: DataSource
    var date: Date

    /// The consumed calories.
    var calories: Double

    init(
        _ calories: Double, on date: Date? = Date(),
        from source: DataSource? = .CoreData
    ) {
        self.source = source ?? self.source
        self.date = date ?? self.date
        self.calories = calories
    }
}

/// Entry of burned calories.
@Model
final class CaloriesBurned: DataModel {
    var source: DataSource
    var date: Date

    /// The burned calories.
    var calories: Double
    /// The duration of the activity.
    var duration: TimeInterval

    init(
        _ calories: Double, on date: Date = Date(),
        over duration: TimeInterval = 0, from source: DataSource = .CoreData
    ) {
        self.date = date
        self.duration = duration
        self.calories = calories
        self.source = source
    }
}
