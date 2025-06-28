import Foundation
import SwiftUI
import WidgetKit

// MARK: Budget Service
// ============================================================================

public struct MacrosAnalyticsService: Sendable {
    let calories: BudgetService?
    let protein: DataAnalyticsService
    let carbs: DataAnalyticsService
    let fat: DataAnalyticsService

    /// User-defined budget adjustment (kcal)
    let adjustments: CalorieMacros?
    /// The days until the next week starts
    let daysLeft: Int

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
            p: budget.protein.map { $0 + (credits?.protein ?? 0) / Double(daysLeft) },
            f: budget.fat.map { $0 + (credits?.fat ?? 0) / Double(daysLeft) },
            c: budget.carbs.map { $0 + (credits?.carbs ?? 0) / Double(daysLeft) }
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

// MARK: Macros Observation
// ============================================================================

extension MacrosAnalyticsService {
    /// Start observing for calories and weight data updates
    public func startObserver(
        _ healthKit: HealthKitService, callback: @escaping @Sendable () -> Void
    ) {
        if let intakeRange = protein.intakeDateRange,
            let currentRange = protein.currentIntakeDateRange
        {
            healthKit.startObserving(
                for: MacrosWidgetID, dataTypes: [.protein],
                from: intakeRange.from, to: currentRange.to,
                onUpdate: { callback() }
            )
        }

        if let intakeRange = carbs.intakeDateRange,
            let currentRange = carbs.currentIntakeDateRange
        {
            healthKit.startObserving(
                for: MacrosWidgetID, dataTypes: [.carbs],
                from: intakeRange.from, to: currentRange.to,
                onUpdate: { callback() }
            )
        }

        if let intakeRange = fat.intakeDateRange,
            let currentRange = fat.currentIntakeDateRange
        {
            healthKit.startObserving(
                for: MacrosWidgetID, dataTypes: [.fat],
                from: intakeRange.from, to: currentRange.to,
                onUpdate: { callback() }
            )
        }
    }
}
