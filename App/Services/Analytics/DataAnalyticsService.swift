import Foundation
import SwiftData
import SwiftUI

// MARK: Calorie Analytics Service
// ============================================================================

struct DataAnalyticsService {
    let analytics: AnalyticsService

    /// Current intakes (kcal), oldest first
    let currentIntakes: [Date: Double]
    /// Historical daily intakes (kcal), oldest first
    let intakes: [Date: Double]
    /// EWMA smoothing factor (e.g. 0.25 for 7-day smoothing [α = 2/(7+1)])
    let alpha: Double

    /// Daily intake buckets.
    var dailyIntakes: [Date: Double] {
        return intakes.bucketed(by: .day).mapValues { $0.sum() }
    }

    /// EWMA-smoothed intake S (kcal)
    var smoothedIntake: Double? {
        return analytics.computeEWMA(
            from: dailyIntakes.points, alpha: alpha
        )
    }

    /// Total current intake (kcal)
    var currentIntake: Double? {
        return currentIntakes.bucketed(by: .day)
            .mapValues { $0.sum() }
            .values.first
    }

    /// Whether the maintenance estimate has enough data to be valid.
    var isValid: Bool {
        let max = dailyIntakes.keys.sorted().max()
        let min = dailyIntakes.keys.sorted().min()
        guard let max: Date = max, let min: Date = min else { return false }

        // Data points must span at least 1 week
        return min.distance(to: max, in: .weekOfYear) ?? 0 >= 1
    }

    /// Get the date range of the EWMA calculation.
    static func ewmaDateRange(
        from date: Date
    ) -> (from: Date, to: Date) {
        return (
            from: date.floored(to: .day).adding(-7, .day),
            to: date.floored(to: .day).adding(-1, .second),
        )
    }

    /// Get the date range of the current calculations.
    static func currentDateRange(
        from date: Date
    ) -> (from: Date, to: Date) {
        return (from: date.floored(to: .day), to: date)
    }

    /// Get the date range of the maintenance calculations.
    static func fittingDateRange(
        from date: Date
    ) -> (from: Date, to: Date) {
        return (
            from: date.floored(to: .day).adding(-14, .day), to: date,
        )
    }
}
