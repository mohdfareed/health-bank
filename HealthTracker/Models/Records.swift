import Foundation
import SwiftData

// MARK: Calories
// ============================================================================

/// A protocol for all calorie records.
protocol Calorie: DataRecord {
    /// The date the record was created.
    var date: Date { get }
    /// The calories consumed or burned.
    var calories: Double { get }
}

protocol BurnedCalorie: Calorie {}
protocol RestingCalorie: BurnedCalorie {}
protocol ActiveCalorie: BurnedCalorie {}
protocol DietaryCalorie: Calorie {
    /// The macros breakdown.
    var macros: CalorieMacros? { get }
}

/// A nutrition calorie macros breakdown.
struct CalorieMacros: Codable, Hashable {
    /// The protein breakdown.
    var protein: Double? = nil
    /// The fat breakdown.
    var fat: Double? = nil
    /// The carbs breakdown.
    var carbs: Double? = nil
}

// MARK: Weight
// ============================================================================

/// A protocol for all weight records.
protocol Weight: DataRecord {
    /// The date the record was created.
    var date: Date { get }
    /// The current weight.
    var weight: Double { get }
}

// MARK: Workout
// ============================================================================

/// The workout types.
enum WorkoutType: CaseIterable, Codable {
    case cardio, weightlifting, cycling, other
}

/// A protocol for all workouts.
protocol Workout: ActiveCalorie, DataRecord {
    /// The date the record was created.
    var date: Date { get }
    /// The calories burned.
    var calories: Double { get }
    /// The workout duration.
    var duration: TimeInterval { get }
    /// The workout type.
    var type: WorkoutType { get }
}
