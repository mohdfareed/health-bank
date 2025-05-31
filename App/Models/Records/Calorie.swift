import Foundation
import SwiftData

// MARK: - Calories
// ============================================================================

/// Protocol defining the basic properties for any calorie entry.
/// All calorie values are stored in kilocalories (kcal).
public protocol Calorie: HealthRecord {
    /// Energy value in kilocalories.
    var calories: Double { get nonmutating set }
}

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

// MARK: - Dietary Calories
// ============================================================================

/// Represents dietary calorie intake.
@Model public final class DietaryCalorie: Calorie {
    public var calories: Double
    public var date: Date
    public var source: DataSource

    // Optional macro-nutrient breakdown
    public var macros: CalorieMacros?

    public init(
        _ value: Double, date: Date = Date(), source: DataSource = .local,
        macros: CalorieMacros? = nil
    ) {
        self.calories = value
        self.date = date
        self.source = source
        self.macros = macros
    }
}

// MARK: - Resting Energy
// ============================================================================

/// Represents resting energy expenditure (basal metabolic rate).
@Model public final class RestingEnergy: Calorie {
    public var calories: Double
    public var date: Date
    public var source: DataSource

    public init(
        _ value: Double, date: Date = Date(), source: DataSource = .local
    ) {
        self.calories = value
        self.date = date
        self.source = source
    }
}
