import Foundation

// MARK: Calorie Queries
// ============================================================================

/// A query for calories consumed or burned.
struct CalorieQuery<C: Calorie>: RemoteQuery {
    typealias Model = C
    /// The date range of the query, inclusive.
    let (from, to): (starting: Date, ending: Date)
    /// The minimum and maximum calories.
    let (min, max): (min: Double, max: Double)
}

/// A query of only consumed calories with macros breakdown.
struct MacrosQuery<C: DietaryCalorie>: RemoteQuery {
    typealias Model = C
    /// The calories consumed query.
    var calories: CalorieQuery<C>
}

// MARK: Weight
// ============================================================================

/// A query for weight records.
struct WeightQuery<C: Weight>: RemoteQuery {
    typealias Model = C
    /// The date range of the query, inclusive.
    let (from, to): (starting: Date, ending: Date)
    /// The minimum and maximum weight.
    let (min, max): (min: Double, max: Double)
}

// MARK: Workout
// ============================================================================

/// A query for weight records.
struct WorkoutQuery<C: Workout>: RemoteQuery {
    typealias Model = C
    /// The calories consumed query.
    var calories: CalorieQuery<C>
    /// The workout type.
    let types: [WorkoutType]
}

// MARK: Units
// ============================================================================

extension UnitDefinition {
    /// The unit for calories consumed.
    static var calorie: UnitDefinition<UnitEnergy> {
        .init(.kilocalories, usage: .food)
    }

    /// The unit for a calorie macros breakdown.
    static var macro: UnitDefinition<UnitMass> {
        .init(.grams, usage: .asProvided)
    }

    /// The unit for a weight record.
    static var weight: UnitDefinition<UnitMass> {
        .init(.kilograms, usage: .personWeight)
    }

    /// The unit for a workout duration.
    static var workout: UnitDefinition<UnitDuration> {
        .init(.minutes, alts: [.minutes, .hours])
    }
}
