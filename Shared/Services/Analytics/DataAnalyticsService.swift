import Foundation
import SwiftData
import SwiftUI

// MARK: Calorie Analytics Service
// ============================================================================

public struct DataAnalyticsService: Sendable {
    /// Current intakes (kcal)
    let currentIntakes: [Date: Double]
    /// Historical daily intakes (kcal)
    let intakes: [Date: Double]
    /// EWMA smoothing factor (e.g. 0.25 for 7-day smoothing [α = 2/(7+1)])
    let alpha: Double

    /// Daily intake buckets.
    var dailyIntakes: [Date: Double] {
        return intakes.bucketed(by: .day, using: .autoupdatingCurrent)
            .mapValues { $0.sum() }
    }

    /// The date range for intake data.
    var intakeDateRange: (from: Date, to: Date)? {
        let max = dailyIntakes.keys.sorted().max()
        let min = dailyIntakes.keys.sorted().min()
        guard let max: Date = max, let min: Date = min else { return nil }
        return (from: min, to: max)
    }

    /// The date range for current intake data.
    var currentIntakeDateRange: (from: Date, to: Date)? {
        let max = currentIntakes.keys.sorted().max()
        let min = currentIntakes.keys.sorted().min()
        guard let max: Date = max, let min: Date = min else { return nil }
        return (from: min, to: max)
    }

    /// EWMA-smoothed intake S
    public var smoothedIntake: Double? {
        return computeEWMA(
            from: dailyIntakes.points, alpha: alpha
        )
    }

    /// Total current intake
    public var currentIntake: Double? {
        return currentIntakes.values.sum()
    }

    /// Computes the EWMA of a series of values.
    /// - Parameters:
    ///   - values: historical values [C₀, C₁, …, Cₜ₋₁] (oldest first)
    ///   - alpha: EWMA smoothing factor (0 < α < 1)
    /// - Returns: Sₜ where
    ///   S₀ = C₀
    ///   Sᵢ = α·Cᵢ + (1−α)·Sᵢ₋₁
    func computeEWMA(from values: [Double], alpha: Double) -> Double? {
        guard !values.isEmpty else { return nil }
        // Seed with the first data point
        var smoothed = values[0]
        // Fold over the rest (last has highest weight)
        for value in values.dropFirst() {
            smoothed = alpha * value + (1 - alpha) * smoothed
        }
        return smoothed
    }
}
