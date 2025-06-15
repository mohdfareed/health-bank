import Foundation

// MARK: Budget Service
// ============================================================================

struct BudgetService {
    let analytics: AnalyticsService

    /// Historical daily intakes (kcal), oldest first
    let intakes: [Date: Double]
    /// EWMA smoothing factor (e.g. 0.25 for 7-day smoothing [α = 2/(7+1)])
    let alpha: Double
    /// User-defined daily calorie budget (kcal)
    let budget: Double

    /// Daily intake buckets.
    var dailyIntakes: [Date: Double] {
        return intakes.bucketed(by: .day).mapValues { $0.sum() }
    }

    /// EWMA-smoothed intake Sₜ (kcal)
    var smoothedIntake: Double {
        return analytics.computeEWMA(from: dailyIntakes.points, alpha: alpha)
    }

    /// Today's calorie intake ICₜ (kcal)
    var intake: Double {
        dailyIntakes[Date().floored(to: .day)] ?? 0
    }

    /// Daily calorie credit: Cₜ = B - Sₜ (kcal)
    var credit: Double {
        budget - smoothedIntake
    }

    /// Remaining budget for today: Rₜ = B - ICₜ (kcal)
    var remaining: Double {
        budget - intake
    }
}
