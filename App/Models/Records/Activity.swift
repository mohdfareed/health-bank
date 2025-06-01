import Foundation
import SwiftData

/// The workout types.
public typealias WorkoutType = HealthKitService.WorkoutType

/// Represents active energy expenditure from physical activity.
@Model public final class ActiveEnergy: Calorie {
    public var calories: Double
    public var date: Date
    public var source: DataSource

    /// The workout duration.
    public var duration: TimeInterval?
    /// The workout type.
    public var workout: WorkoutType?

    public init(
        _ value: Double, date: Date = Date(), source: DataSource = .local,
        duration: TimeInterval? = nil, workout: WorkoutType? = nil,
    ) {
        self.calories = value
        self.date = date
        self.duration = duration
        self.workout = workout
        self.source = source
    }
}
