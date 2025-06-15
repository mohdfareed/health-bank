import Foundation

/// Encapsulates maintenance estimation calculations for display in widgets.
struct MaintenanceService {
    let analytics: AnalyticsService
    let budget: BudgetService

    /// Recent daily weights (lbs), oldest first
    let weights: [Date: Double]
    /// Energy per unit weight change (kcal per kg, default is 7700)
    let rho: Double

    /// Daily weight buckets.
    var dailyWeights: [Date: Double] {
        return weights.bucketed(by: .day)
            .mapValues { $0.average() ?? .nan }
            .filter { !$0.value.isNaN }
    }

    /// Estimated weight-change rate m (lbs/day)
    var weightSlope: Double {
        analytics.computeSlope(from: dailyWeights.points)
    }

    /// Projected weekly trend from weight data (lbs/week)
    var weeklyTrend: Double {
        weightSlope * 7
    }

    /// Daily energy imbalance ΔEₜ = m * rho (kcal/day)
    var energyImbalance: Double {
        weightSlope * rho
    }

    /// Raw maintenance estimate Mₜ = Sₜ - ΔEₜ (kcal/day)
    var maintenance: Double {
        budget.smoothedIntake - energyImbalance
    }
}
