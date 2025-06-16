import Foundation
import SwiftUI

// MARK: Budget Service
// ============================================================================

struct MacrosAnalyticsService {
    let budget: BudgetService?
    let protein: DataAnalyticsService
    let carbs: DataAnalyticsService
    let fat: DataAnalyticsService

    /// User-defined budget adjustment (kcal)
    let adjustments: CalorieMacros?
    /// The days until the next week starts
    let daysLeft: Int

    /// The base daily budget: B = M + A (kcal)
    var baseBudgets: CalorieMacros? {
        guard let budget = budget?.baseBudget else { return nil }
        guard let adjustments = adjustments else { return nil }
        let macroCalories = CalorieMacros(
            p: adjustments.protein == nil ? nil : budget * (adjustments.protein ?? 0) / 100,
            f: adjustments.fat == nil ? nil : budget * (adjustments.fat ?? 0) / 100,
            c: adjustments.carbs == nil ? nil : budget * (adjustments.carbs ?? 0) / 100,
        )

        // convert calories to grams
        return CalorieMacros(
            p: macroCalories.protein.map { $0 / 4 },
            f: macroCalories.fat.map { $0 / 9 },
            c: macroCalories.carbs.map { $0 / 4 }
        )
    }

    /// Daily calorie credit: C = B - S (kcal)
    var credits: CalorieMacros? {
        guard let protein = protein.smoothedIntake else { return nil }
        guard let carbs = carbs.smoothedIntake else { return nil }
        guard let fat = fat.smoothedIntake else { return nil }
        guard let budget = baseBudgets else { return nil }

        return CalorieMacros(
            p: budget.protein.map { $0 - protein },
            f: budget.fat.map { $0 - fat },
            c: budget.carbs.map { $0 - carbs }
        )
    }

    /// The adjusted budget for
    /// Adjusted budget: B' = B + C/D (kcal), where D = days until next week
    var budgets: CalorieMacros? {
        guard let budget = baseBudgets else { return nil }
        guard let credits = credits else { return nil }

        return CalorieMacros(
            p: budget.protein.map { $0 + (credits.protein ?? 0) / Double(daysLeft) },
            f: budget.fat.map { $0 + (credits.fat ?? 0) / Double(daysLeft) },
            c: budget.carbs.map { $0 + (credits.carbs ?? 0) / Double(daysLeft) }
        )
    }

    /// The remaining budget for today
    var remaining: CalorieMacros? {
        guard let budget = budgets else { return nil }
        guard let protein = protein.currentIntake else { return nil }
        guard let carbs = carbs.currentIntake else { return nil }
        guard let fat = fat.currentIntake else { return nil }

        return CalorieMacros(
            p: budget.protein.map { $0 - protein },
            f: budget.fat.map { $0 - fat },
            c: budget.carbs.map { $0 - carbs }
        )
    }
}
