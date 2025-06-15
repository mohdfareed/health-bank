import Foundation
import SwiftUI

// MARK: Budget Service
// ============================================================================

struct BudgetService {
    let analytics: AnalyticsService

    /// Historical daily intakes (kcal), oldest first
    let intakes: [Date: Double]
    /// EWMA smoothing factor (e.g. 0.25 for 7-day smoothing [α = 2/(7+1)])
    let alpha: Double
    /// User-defined daily calorie budget (kcal)
    let budget: Double?

    /// Daily intake buckets.
    var dailyIntakes: [Date: Double] {
        return intakes.bucketed(by: .day).mapValues { $0.sum() }
    }

    /// Historical intakes excluding today (kcal), oldest first
    var historicalIntakes: [Date: Double] {
        return dailyIntakes.filter { $0.key < Date().floored(to: .day) }
    }

    /// EWMA-smoothed intake Sₜ (kcal)
    var smoothedIntake: Double? {
        return analytics.computeEWMA(
            from: historicalIntakes.points, alpha: alpha
        )
    }

    /// Today's calorie intake ICₜ (kcal)
    var intake: Double {
        dailyIntakes[Date().floored(to: .day)] ?? 0
    }

    /// Daily calorie credit: Cₜ = B - Sₜ (kcal)
    var credit: Double? {
        guard let smoothed = smoothedIntake else { return nil }
        guard let budget = budget else { return nil }
        return budget - smoothed
    }

    /// Remaining budget for today: Rₜ = B - ICₜ (kcal)
    var remaining: Double? {
        guard let budget = budget else { return nil }
        return budget - intake
    }
}

extension BudgetService {
    @ViewBuilder
    func progress(color: Color = .accent, icon: Image?) -> ProgressRing {
        ProgressRing(
            value: self.budget ?? 1,
            progress: (self.budget ?? 0) - (self.remaining ?? 0),
            color: (self.remaining ?? 0) >= 0 ? color : .red,
            tip: (self.budget ?? 1) + (self.credit ?? 0),
            tipColor: (self.credit ?? 0) >= 0 ? .green : .red,
            icon: icon
        )
    }
}
