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
        guard let maintenance = weight.maintenance else { return nil }
        return maintenance + (adjustment ?? 0)
    }

    /// Daily calorie credit: C = B - S (kcal)
    var credit: Double? {
        guard let smoothed = calories.smoothedIntake else { return nil }
        guard let budget = baseBudget else { return nil }
        return budget - smoothed
    }

    /// The adjusted budget for
    /// Adjusted budget: B' = B + C/D (kcal), where D = days until next week
    var budget: Double? {
        guard let budget = baseBudget else { return nil }
        guard let credit = credit else { return nil }
        return budget + (credit / Double(daysLeft))
    }

    /// The remaining budget for today
    var remaining: Double? {
        guard let budget = budget else { return nil }
        guard let intake = calories.currentIntake else { return nil }
        return budget - intake
    }
}
