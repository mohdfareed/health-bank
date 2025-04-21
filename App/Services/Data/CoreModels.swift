import Foundation
import SwiftData

// MARK: Calorie Models
// ============================================================================

@Model final class CoreDietaryCalorie: DietaryCalorie {
    var source: DataSource
    var date: Date
    var calories: Double
    var macros: CalorieMacros?

    init(
        _ calories: Double, macros: CalorieMacros? = nil,
        on date: Date = Date(), from source: DataSource = .init()
    ) {
        self.source = source
        self.date = date
        self.calories = calories
        self.macros = macros
    }
}

@Model final class CoreRestingCalorie: RestingCalorie {
    var source: DataSource
    var date: Date
    var calories: Double
    init(_ calories: Double, on date: Date, from source: DataSource) {
        self.source = source
        self.date = date
        self.calories = calories
    }
}

@Model final class CoreWorkout: Workout {
    var source: DataSource
    var date: Date
    var calories: Double
    var duration: TimeInterval
    var type: WorkoutType

    init(
        _ calories: Double, over duration: TimeInterval, type: WorkoutType,
        on date: Date = Date(), from source: DataSource = .init()
    ) {
        self.source = source
        self.date = date
        self.calories = calories
        self.duration = duration
        self.type = type
    }
}
