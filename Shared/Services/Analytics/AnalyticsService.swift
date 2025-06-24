import Foundation

// MARK: Analytics Service
// ============================================================================

public struct AnalyticsService: Sendable {
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
