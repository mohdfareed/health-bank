import Foundation

/// Statistics service for a budget cycle.
//  - Note: If not date is provided, the current date is dynamically evaluated.
struct CalorieStatisticsService {
    internal let logger = AppLogger.new(category: "\(CalorieStatisticsService.self)")

    let budget: CalorieBudget
    let entries: [CalorieEntry]
    let staticDate: Date?

    /// The reference date for the statistics.
    var date: Date {
        return staticDate ?? Date.now
    }

    /// The start date of the budget cycle.
    var start: Date {
        return self.budget.calcDateRange(for: self.date).start
    }

    /// The end date of the budget cycle.
    var end: Date {
        return self.budget.calcDateRange(for: self.date).end
    }

    /// The budget cycle calories.
    var caloriesBudget: Int {
        return self.budget.calories
    }

    /// The total consumed calories.
    var consumedCalories: Int {
        return self.entries.totalCalories
    }

    /// The total remaining calories.
    var remainingCalories: Int {
        return self.caloriesBudget - self.consumedCalories
    }

    /// The daily budget.
    var dailyBudget: Int {
        let remainingDays = self.budget.calcRemainingDays(for: self.date)
        if remainingDays == 0 {
            return 0
        }

        let entries = self.entries.filter { $0.date < self.date }
        let remaining = self.budget.calories - entries.totalCalories
        let budget = remaining / remainingDays
        return budget
    }

    /// The consumed calories for a given day.
    var dailyConsumed: Int {
        let total = self.entries.filter { $0.date == self.date }.totalCalories
        return total
    }

    /// The remaining calories for a given day.
    var dailyRemaining: Int {
        let remaining = self.dailyBudget - self.dailyConsumed
        return remaining
    }

    init(
        for budget: CalorieBudget, using entries: [CalorieEntry], at date: Date? = nil
    ) {
        self.staticDate = date
        self.budget = budget
        self.entries = entries
        self.logger.debug("Statistics service initialized for budget: \(budget.name)")
    }
}
