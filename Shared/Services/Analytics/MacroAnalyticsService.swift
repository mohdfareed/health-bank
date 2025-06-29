import Foundation
import SwiftUI
import WidgetKit

// MARK: Budget Service
// ============================================================================

public struct MacrosAnalyticsService: Sendable {
    // MARK: - Types

    /// Represents the different macro nutrients for ring display
    public enum MacroRing: CaseIterable {
        case protein
        case carbs
        case fat
    }

    // MARK: - Properties

    let calories: BudgetService?
    let protein: DataAnalyticsService
    let carbs: DataAnalyticsService
    let fat: DataAnalyticsService

    /// User-defined budget adjustment (kcal)
    let adjustments: CalorieMacros?

    /// The base daily budget: B = M + A (kcal)
    var baseBudgets: CalorieMacros? {
        guard let adjustments = adjustments else { return nil }
        guard let budget = calories?.baseBudget else { return nil }

        // Calculate the macro budgets based on the adjustments
        let macroCalories = CalorieMacros(
            p: adjustments.protein == nil ? nil : budget * adjustments.protein! / 100,
            f: adjustments.fat == nil ? nil : budget * adjustments.fat! / 100,
            c: adjustments.carbs == nil ? nil : budget * adjustments.carbs! / 100,
        )

        // convert calories to grams
        return CalorieMacros(
            p: macroCalories.protein.map { $0 / 4 },
            f: macroCalories.fat.map { $0 / 9 },
            c: macroCalories.carbs.map { $0 / 4 }
        )
    }

    /// Daily calorie credit: C = B - S (kcal)
    public var credits: CalorieMacros? {
        guard let budget = baseBudgets else { return nil }
        return CalorieMacros(
            p: budget.protein.map { $0 - (protein.smoothedIntake ?? 0) },
            f: budget.fat.map { $0 - (fat.smoothedIntake ?? 0) },
            c: budget.carbs.map { $0 - (carbs.smoothedIntake ?? 0) }
        )
    }

    /// The adjusted budget for
    /// Adjusted budget: B' = B + C/D (kcal), where D = days until next week
    public var budgets: CalorieMacros? {
        guard let budget = baseBudgets else { return nil }
        return CalorieMacros(
            p: budget.protein.map {
                $0 + (credits?.protein ?? 0) / Double(calories?.daysLeft ?? 7)
            },
            f: budget.fat.map {
                $0 + (credits?.fat ?? 0) / Double(calories?.daysLeft ?? 7)
            },
            c: budget.carbs.map {
                $0 + (credits?.carbs ?? 0) / Double(calories?.daysLeft ?? 7)
            }
        )
    }

    /// The remaining budget for today
    public var remaining: CalorieMacros? {
        guard let budget = budgets else { return nil }
        return CalorieMacros(
            p: budget.protein.map { $0 - (protein.currentIntake ?? 0) },
            f: budget.fat.map { $0 - (fat.currentIntake ?? 0) },
            c: budget.carbs.map { $0 - (carbs.currentIntake ?? 0) }
        )
    }
}
