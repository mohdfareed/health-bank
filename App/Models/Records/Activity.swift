import Foundation
import SwiftData

/// The workout types.
public enum WorkoutType: String, Codable, CaseIterable {
    case cardio, weightlifting, cycling, walking, running, other
}

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
        duration: TimeInterval? = nil, workoutType: WorkoutType? = nil,
    ) {
        self.calories = value
        self.date = date
        self.duration = duration
        self.workout = workoutType
        self.source = source
    }
}
