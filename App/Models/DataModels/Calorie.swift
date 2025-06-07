import Foundation
import SwiftData

// MARK: - Calories
// ============================================================================

/// Protocol defining the basic properties for any calorie entry.
/// All calorie values are stored in kilocalories (kcal).
public protocol Calorie: HealthData {
    /// Energy value in kilocalories.
    var calories: Double { get set }
}

/// Represents macro-nutrient breakdown of calories.
public struct CalorieMacros: Codable, Hashable, Sendable {
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
public final class DietaryCalorie: Calorie {
    public var id: UUID
    public let source: DataSource
    public var date: Date

    public var calories: Double
    // Optional macro-nutrient breakdown
    public var macros: CalorieMacros?

    public init(
        _ value: Double, macros: CalorieMacros? = nil,
        id: UUID = UUID(),
        source: DataSource = .app,
        date: Date = Date(),

    ) {
        self.calories = value
        self.macros = macros

        self.id = id
        self.source = source
        self.date = date
    }
}
