import Foundation
import HealthKit
import SwiftData

/// The workout types.
public enum WorkoutActivity: Codable, CaseIterable, Hashable {
    case cardio, cycling, swimming, weightlifting
    case dancing, boxing, martialArts
}

/// Represents active energy expenditure from physical activity.
public final class ActiveEnergy: Calorie {
    public var id: UUID
    public let source: DataSource
    public var date: Date

    public var calories: Double
    /// The workout duration.
    public var duration: TimeInterval?
    /// The workout type.
    public var workout: WorkoutActivity?

    public init(
        _ value: Double,
        duration: TimeInterval? = nil, workout: WorkoutActivity? = nil,
        id: UUID = UUID(),
        source: DataSource = .app,
        date: Date = Date(),
    ) {
        self.calories = value
        self.duration = duration
        self.workout = workout

        self.id = id
        self.source = source
        self.date = date
    }
}
