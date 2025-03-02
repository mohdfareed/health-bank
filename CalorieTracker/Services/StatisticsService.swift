import Foundation

/// Statistics service for a budget cycle.
struct CalorieStatisticsService {
    internal let logger = AppLogger.new(category: "\(CalorieStatisticsService.self)")
    private let budgetService: CalorieBudgetService
    private let caloriesService: CaloriesService

    private let budget_name: String
    private let static_date: Date?

    /// The budget used for statistics.
    var budget: CalorieBudget {
        return try! budgetService.get(budget_name)
    }

    /// The calorie entries for the budget cycle.
    var entries: [CalorieEntry] {
        return try! caloriesService.get(from: self.start, to: self.end)
    }

    /// The reference date for the statistics.
    var date: Date {
        return static_date ?? Date.now
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
        budgetService: CalorieBudgetService, caloriesService: CaloriesService, at date: Date? = nil,
        for budgetName: String? = nil
    ) throws {
        let budgetName = budgetName ?? "Default Budget"

        self.budgetService = budgetService
        self.caloriesService = caloriesService
        self.budget_name = budgetName
        self.static_date = date

        self.logger.debug("Statistics service initialized for: \(budgetName)")
    }
}
