import Foundation
import SwiftData

/// Protocol defining the basic properties for any calorie entry.
/// All calorie values are stored in kilocalories (kcal).
public protocol Calorie: DataRecord {
    /// Energy value in kilocalories.
    var calories: Double { get set }
}

// MARK: - Dietary Calories
// ============================================================================

/// Represents macro-nutrient breakdown of calories.
public struct CalorieMacros: Codable, Hashable {
    /// Protein contents in grams.
    public var protein: Double?
    /// Fat contents in grams.
    public var fat: Double?
    /// Carbohydrate contents in grams.
    public var carbs: Double?

    public init(p: Double? = nil, f: Double? = nil, c: Double? = nil) {
        self.protein = p
        self.fat = f
        self.carbs = c
    }
}

/// Represents dietary calorie intake.
@Model public final class DietaryEnergy: Calorie {
    public var calories: Double
    public var date: Date
    public var source: DataSource

    // Optional macro-nutrient breakdown
    public var macros: CalorieMacros?

    public init(
        _ value: Double, date: Date, source: DataSource,
        macros: CalorieMacros? = nil
    ) {
        self.calories = value
        self.date = date
        self.source = source
        self.macros = macros
    }
}

// MARK: - Active Calories
// ============================================================================

/// The workout types.
public enum WorkoutType: Codable, CaseIterable {
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
    public var workoutType: WorkoutType?

    public init(
        _ value: Double, date: Date, source: DataSource = .local,
        duration: TimeInterval? = nil, workoutType: WorkoutType? = nil,
    ) {
        self.calories = value
        self.date = date
        self.duration = duration
        self.workoutType = workoutType
        self.source = source
    }
}

/// Represents resting energy expenditure (basal metabolic rate).
@Model public final class RestingEnergy: Calorie {
    public var calories: Double
    public var date: Date
    public var source: DataSource

    public init(_ value: Double, date: Date, source: DataSource) {
        self.calories = value
        self.date = date
        self.source = source
    }
}
