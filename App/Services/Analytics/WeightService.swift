import Foundation
import SwiftData
import SwiftUI

/// Encapsulates maintenance estimation calculations for display in widgets.
struct WeightAnalyticsService {
    let analytics: AnalyticsService
    let calories: DataAnalyticsService

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

    /// Daily energy imbalance ΔE = m * rho (kcal/day)
    var energyImbalance: Double {
        weightSlope * rho
    }

    /// Raw maintenance estimate M = S - ΔE (kcal/day)
    var maintenance: Double? {
        guard let smoothed = calories.smoothedIntake else { return nil }
        return smoothed - energyImbalance
    }
}
