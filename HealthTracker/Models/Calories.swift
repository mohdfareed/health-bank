import Foundation
import SwiftData

// MARK: Calorie Models
// ============================================================================

/// A protocol for all calorie records.
protocol Calorie: DataRecord {
    /// The date the record was created.
    var date: Date { get }
    /// The calories consumed or burned.
    /// Positive values are consumed and negative values are burned.
    var calories: Double { get }
}

/// A calorie burned through activity.
protocol ActivityCalorie: Calorie {}

/// A calorie burned through basal metabolism.
protocol RestingCalorie: Calorie {}

/// A calorie consumed through nutrition.
protocol NutritionCalorie: Calorie {
    /// The calorie macros breakdown.
    var macros: CalorieMacros? { get }
}

/// A nutrition calorie macros breakdown.
struct CalorieMacros: Codable, Equatable {
    /// The protein breakdown.
    var protein: Double? = nil
    /// The fat breakdown.
    var fat: Double? = nil
    /// The carbs breakdown.
    var carbs: Double? = nil
}

// MARK: Calories Queries
// ============================================================================

/// A query for calories consumed or burned.
struct CalorieQuery<C: Calorie>: RemoteQuery {
    typealias Model = C
    /// The minimum date.
    let from: Date = Date().floored(to: .day)
    /// The maximum date.
    let to: Date = Date()
}

/// A query for calories consumed with macros breakdown.
struct MacrosCalorieQuery<C: NutritionCalorie>: RemoteQuery {
    typealias Model = C
    /// The calories query.
    let calories: CalorieQuery<C>
}

// MARK: Calorie Budget
// ============================================================================

/// A daily budget of calories and macro-nutrients.
@Model final class CalorieBudget: Singleton {
    typealias ID = UUID
    var id: UUID = UUID()
    init() {}

    /// The date the budget was set.
    var date: Date = Date()
    /// The daily calorie budget.
    var calories: Double? = 2000
    /// The daily calorie macros budgets.
    var macros: CalorieMacros = CalorieMacros(
        protein: 120, fat: 60, carbs: 245
    )
}
