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

    /// Smoothing window length for weight EWMA (days)
    let alpha: Double

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
        return weightSlope * rho
    }

    /// Estimated weight-change rate m (kg/day)
    public var weightSlope: Double {
        computeSlope(from: dailyWeights)
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
        ) ?? 0 >= 14
    }

    /// EWMA-smoothed weight series (oldest first)
    private var smoothedWeightsSeries: [(date: Date, value: Double)] {
        let sorted = dailyWeights.sorted { $0.key < $1.key }
        guard !sorted.isEmpty else { return [] }

        var series: [(Date, Double)] = []
        var smoothed = sorted[0].value
        series.append((sorted[0].key, smoothed))

        for (date, value) in sorted.dropFirst() {
            smoothed = alpha * value + (1 - alpha) * smoothed
            series.append((date, smoothed))
        }
        return series
    }

    /// Computes the slope (Δy/Δx) of time-series data using least-squares linear regression.
    /// - Parameters:
    ///   - values: a dictionary of date-value pairs representing weight measurements
    /// - Returns: the slope in units per day (e.g., kg/day)
    func computeSlope(from values: [Date: Double]) -> Double {
        // Use smoothed weight series
        let series = smoothedWeightsSeries
        guard series.count > 1 else { return 0 }

        // Convert to (t, w) arrays
        let t = series.map { $0.date.timeIntervalSince(series.first!.date) / 86_400 }
        let w = series.map { $0.value }
        let n = t.count

        let meanX = t.reduce(0, +) / Double(n)
        let meanY = w.reduce(0, +) / Double(n)

        let numerator = zip(t, w).reduce(0) { acc, pair in
            let (x, y) = pair
            return acc + (x - meanX) * (y - meanY)
        }

        let denominator = t.reduce(0) { acc, x in
            let dx = x - meanX
            return acc + dx * dx
        }
        return denominator != 0 ? numerator / denominator : 0
    }
}
