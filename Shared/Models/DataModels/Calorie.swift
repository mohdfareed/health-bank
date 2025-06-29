import Foundation
import SwiftData

// TODO: Add food name

// MARK: - Calories
// ============================================================================

/// Represents the different macro nutrients for display and configuration
public enum MacroType: String, CaseIterable, Sendable {
    case protein = "protein"
    case carbs = "carbs"
    case fat = "fat"
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

/// Represents dietary calorie intake.
@Observable public final class DietaryCalorie: HealthData, @unchecked Sendable {
    public let id: UUID
    public let source: DataSource
    public var date: Date

    /// Energy value in kilocalories.
    public var calories: Double
    // Optional macro-nutrient breakdown
    public var macros: CalorieMacros?
    /// Alcohol contents in standard drinks.
    public var alcohol: Double?

    public init(
        _ value: Double,
        macros: CalorieMacros? = nil, alcohol: Double? = nil,
        id: UUID = UUID(),
        source: DataSource = .app,
        date: Date = Date(),

    ) {
        self.calories = value
        self.macros = macros
        self.alcohol = alcohol

        self.id = id
        self.source = source
        self.date = date
    }

    public convenience init() {
        self.init(0)
    }
}
