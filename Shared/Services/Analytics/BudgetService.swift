import Foundation
import SwiftUI
import WidgetKit

// MARK: Budget Service
// ============================================================================

public struct BudgetService: Sendable {
    public let calories: DataAnalyticsService
    public let weight: WeightAnalyticsService

    /// User-defined budget adjustment (kcal)
    public let adjustment: Double?
    /// The first day of the week, e.g. Sunday or Monday
    public let firstWeekday: Int

    /// The days until the next budget cycle starts
    public var daysLeft: Int {
        let cal = Calendar.autoupdatingCurrent
        let date = calories.currentIntakeDateRange?.from ?? Date()
        let nextWeek = date.next(firstWeekday, using: cal)!
        let daysLeft = date.distance(to: nextWeek, in: .day, using: cal)!
        return daysLeft
    }

    /// The base daily budget: B = M + A (kcal)
    public var baseBudget: Double? {
        guard let weight = weight.maintenance else { return adjustment }
        guard let adjustment = adjustment else { return weight }
        return weight + adjustment
    }

    /// Daily calorie credit: C = B - S (kcal)
    public var credit: Double? {
        guard let baseBudget = baseBudget else { return nil }
        guard let smoothed = calories.smoothedIntake else { return nil }
        return baseBudget - smoothed
    }

    /// The adjusted budget for
    /// Adjusted budget: B' = B + C/D (kcal), where D = days until next week
    public var budget: Double? {
        guard let baseBudget = baseBudget else { return nil }
        guard let credit = credit else { return baseBudget }
        return baseBudget + (credit / Double(daysLeft))
    }

    /// The remaining budget for today
    public var remaining: Double? {
        guard let budget = budget else { return nil }
        return budget - (calories.currentIntake ?? 0)
    }

    /// Whether the maintenance estimate has enough data to be valid.
    public var isValid: Bool {
        guard let range = calories.intakeDateRange else { return false }

        // Data points must span at least 1 week
        return range.from.distance(
            to: range.to, in: .weekOfYear, using: .autoupdatingCurrent
        ) ?? 0 >= 1
    }
}
