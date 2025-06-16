import Foundation
import SwiftUI

// MARK: Budget Service
// ============================================================================

struct BudgetService {
    let calories: DataAnalyticsService
    let weight: WeightAnalyticsService

    /// User-defined budget adjustment (kcal)
    let adjustment: Double?
    /// The days until the next week starts
    let daysLeft: Int

    /// The base daily budget: B = M + A (kcal)
    var baseBudget: Double? {
        guard let weight = weight.maintenance else { return adjustment }
        guard let adjustment = adjustment else { return weight }
        return weight + adjustment
    }

    /// Daily calorie credit: C = B - S (kcal)
    var credit: Double? {
        guard let baseBudget = baseBudget else { return nil }
        guard let smoothed = calories.smoothedIntake else { return nil }
        return baseBudget - smoothed
    }

    /// The adjusted budget for
    /// Adjusted budget: B' = B + C/D (kcal), where D = days until next week
    var budget: Double? {
        guard let baseBudget = baseBudget else { return nil }
        guard let credit = credit else { return baseBudget }
        return baseBudget + (credit / Double(daysLeft))
    }

    /// The remaining budget for today
    var remaining: Double? {
        guard let budget = budget else { return nil }
        return budget - (calories.currentIntake ?? 0)
    }
}
