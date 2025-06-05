import Foundation
import HealthKit
import SwiftData

/// The workout types.
public enum WorkoutActivity: Codable, CaseIterable, Hashable {
    case cardio, cycling, swimming, weightlifting
    case dancing, boxing, martialArts
}

/// Represents active energy expenditure from physical activity.
@Model public final class ActiveEnergy: Calorie {
    public var calories: Double
    public var date: Date
    public var source: DataSource

    /// The workout duration.
    public var duration: TimeInterval?

    /// The workout type.
    public var workout: WorkoutActivity?

    public init(
        _ value: Double, date: Date = Date(), source: DataSource = .local,
        duration: TimeInterval? = nil, workout: WorkoutActivity? = nil,
    ) {
        self.calories = value
        self.date = date
        self.duration = duration
        self.workout = workout
        self.source = source
    }
}
