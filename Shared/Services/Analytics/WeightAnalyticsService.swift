import Foundation
import SwiftData
import SwiftUI
import WidgetKit

/// Encapsulates maintenance estimation calculations for display in widgets.
public struct WeightAnalyticsService: Sendable {
    let calories: DataAnalyticsService

    /// Recent daily weights (kg), oldest first
    let weights: [Date: Double]
    /// Energy per unit weight change (kcal per kg, default is 7700)
    let rho: Double

    /// Daily weight buckets.
    var dailyWeights: [Date: Double] {
        return weights.bucketed(by: .day, using: .autoupdatingCurrent)
            .mapValues { $0.average() ?? .nan }
            .filter { !$0.value.isNaN }
    }

    /// The date range for weight data.
    var weightDateRange: (from: Date, to: Date)? {
        let max = dailyWeights.keys.sorted().max()
        let min = dailyWeights.keys.sorted().min()
        guard let max: Date = max, let min: Date = min else { return nil }
        return (from: min, to: max)
    }

    /// Daily energy imbalance ΔE = m * rho (kcal/day)
    var energyImbalance: Double {
        weightSlope * rho
    }

    /// Estimated weight-change rate m (kg/day)
    public var weightSlope: Double {
        computeSlope(from: dailyWeights.points)
    }

    /// Raw maintenance estimate M = S - ΔE (kcal/day)
    public var maintenance: Double? {
        guard let smoothed = calories.smoothedIntake else { return nil }
        return smoothed - energyImbalance
    }

    /// Whether the maintenance estimate has enough data to be valid.
    public var isValid: Bool {
        guard let range = weightDateRange else { return false }

        // Data points must span at least 2 weeks
        return range.from.distance(
            to: range.to, in: .weekOfYear, using: .autoupdatingCurrent
        ) ?? 0 >= 2
    }

    /// Computes the slope (Δy/Δx) of a series of equally-spaced samples using
    /// least-squares linear regression.
    /// - Parameters:
    ///   - values: an array of measurements [y₀, y₁, …, yₙ₋₁] (oldest first)
    /// - Returns: the slope (units of y per index, e.g. lbs/day)
    func computeSlope(from values: [Double]) -> Double {
        let n = values.count
        guard n > 1 else { return 0 }

        // x = 0, 1, …, n-1
        let times = (0..<n).map(Double.init)
        let meanX = times.reduce(0, +) / Double(n)
        let meanY = values.reduce(0, +) / Double(n)

        // numerator and denominator
        let numerator = zip(times, values).reduce(0) { acc, pair in
            let (x, y) = pair
            return acc + (x - meanX) * (y - meanY)
        }
        let denominator = times.reduce(0) { acc, x in
            let dx = x - meanX
            return acc + dx * dx
        }
        return denominator != 0 ? numerator / denominator : 0
    }
}
