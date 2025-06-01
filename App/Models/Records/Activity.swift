import Foundation
import HealthKit
import SwiftData

/// The workout types.
public typealias WorkoutType = HealthKitService.WorkoutType
extension WorkoutType: @retroactive CaseIterable, @retroactive Hashable {
    public static var allCases: [Self] {
        return [
            // cardio
            .walking, .running, .hiking, .stairClimbing, .elliptical,
            .mixedCardio, .mixedMetabolicCardioTraining,
            .highIntensityIntervalTraining,
            // weight lifting
            .functionalStrengthTraining, .traditionalStrengthTraining,
            // cycling
            .cycling,
            // dance
            .dance, .danceInspiredTraining, .cardioDance, .socialDance,
            // martial arts
            .boxing, .martialArts,
        ]
    }
}

/// Represents active energy expenditure from physical activity.
@Model public final class ActiveEnergy: Calorie {
    public var calories: Double
    public var date: Date
    public var source: DataSource

    /// The workout duration.
    public var duration: TimeInterval?

    /// The workout type.
    public var workout: WorkoutType? {
        get { workoutType.flatMap(WorkoutType.init(rawValue:)) }
        set { workoutType = newValue?.rawValue }
    }
    private var workoutType: UInt?

    public init(
        _ value: Double, date: Date = Date(), source: DataSource = .local,
        duration: TimeInterval? = nil, workout: WorkoutType? = nil,
    ) {
        self.calories = value
        self.date = date
        self.duration = duration
        self.workoutType = workout?.rawValue
        self.source = source
    }
}
