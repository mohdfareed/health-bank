import Foundation

// MARK: Budget Service
// ============================================================================

struct BudgetService {

    /// Calculates the effective daily budget including running average adjustment.
    /// - Parameters:
    ///   - baseBudget: The user's base daily calorie budget (kcal).
    ///   - averageIntake: The user's running average calorie intake (kcal).
    /// - Returns: The adjusted daily budget.
    public func calculateAdjustedBudget(
        baseBudget: Double,  // 1800
        averageIntake: Double  // 2000
    ) -> Double {
        let surplus = averageIntake - baseBudget  // 200 = 2000 - 1800
        return baseBudget - surplus  // 1600 = 1800 - 200
    }

    /// Distributes a budget adjustment over the remaining days until the next first weekday (including today).
    /// - Parameters:
    ///   - adjustment: The total adjustment amount to distribute (kcal).
    ///   - calendar: The calendar to use for date calculations.
    ///   - currentDate: The current date (defaults to now).
    /// - Returns: The daily adjustment amount to apply to each remaining day.
    public func distributeBudgetAdjustment(
        adjustment: Double,
        calendar: Calendar,
        currentDate: Date = Date()
    ) -> Double {
        let firstWeekDay = currentDate.next(
            calendar.firstWeekday, using: calendar
        )
        let days = currentDate.distance(to: firstWeekDay, in: .day) ?? 0

        guard days > 0 else { return adjustment }
        return adjustment / Double(days)
    }
}
