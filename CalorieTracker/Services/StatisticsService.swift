import Foundation

/// Statistics service for a budget cycle.
struct CalorieStatisticsService {
    let budget: CalorieBudget
    let entries: [CalorieEntry]

    let date: Date
    let (start, end): (Date, Date)

    /// The total consumed calories.
    var consumedCalories: Int {
        return self.entries.totalCalories
    }

    /// The total remaining calories.
    var remainingCalories: Int {
        return self.budget.budget - self.consumedCalories
    }

    /// The daily budget.
    var dailyBudget: Int {
        let remainingDays = self.budget.calcRemainingDays(for: self.date)
        if remainingDays == 0 {
            return 0
        }

        let entries = self.entries.filter { $0.date < self.date }
        let remaining = self.budget.budget - entries.totalCalories
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

    init(budget: CalorieBudget, caloriesService: CaloriesService, date: Date) throws {
        self.budget = budget
        self.date = date

        let (start, end) = budget.calcDateRange(for: date)
        self.start = start
        self.end = end

        self.entries = try caloriesService.entries(from: start, to: end)
    }
}
