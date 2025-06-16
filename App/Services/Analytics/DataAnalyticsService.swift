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
}
