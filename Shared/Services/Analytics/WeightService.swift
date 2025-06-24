import Foundation
import SwiftData
import SwiftUI

/// Encapsulates maintenance estimation calculations for display in widgets.
public struct WeightAnalyticsService: Sendable {
    let analytics: AnalyticsService
    let calories: DataAnalyticsService

    /// Recent daily weights (kg), oldest first
    let weights: [Date: Double]
    /// Energy per unit weight change (kcal per kg, default is 7700)
    let rho: Double

    /// Daily weight buckets.
    var dailyWeights: [Date: Double] {
        return weights.bucketed(by: .day)
            .mapValues { $0.average() ?? .nan }
            .filter { !$0.value.isNaN }
    }

    /// Estimated weight-change rate m (kg/day)
    public var weightSlope: Double {
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

    /// Whether the maintenance estimate has enough data to be valid.
    var isValid: Bool {
        let max = dailyWeights.keys.sorted().max()
        let min = dailyWeights.keys.sorted().min()
        guard let max: Date = max, let min: Date = min else { return false }

        // Data points must span at least 2 weeks
        return min.distance(to: max, in: .weekOfYear) ?? 0 >= 2
    }
}
