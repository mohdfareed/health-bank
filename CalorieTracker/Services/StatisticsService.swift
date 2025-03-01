import Foundation

/// Statistics service for a budget cycle.
struct CalorieStatisticsService {
    private let budget: CalorieBudget
    private let entries: [CalorieEntry]
    private let (start, end): (Date, Date)

    /// The total consumed calories.
    var consumedCalories: Int {
        return self.entries.totalCalories
    }

    /// The total remaining calories.
    var remainingCalories: Int {
        return self.budget.budget - self.consumedCalories
    }

    init(budget: CalorieBudget, caloriesService: CaloriesService, date: Date) throws {
        self.budget = budget

        let (start, end) = budget.calcDateRange(for: date)
        self.start = start
        self.end = end

        self.entries = try caloriesService.entries(from: start, to: end)
    }

    /// Calculate the daily budget.
    /// - Parameter date: The date for which to calculate.
    /// - Returns: The daily budget.
    func calcDailyBudget(for date: Date) throws -> Int {
        try self.validateDate(date)
        let remainingDays = self.budget.calcRemainingDays(for: date)
        if remainingDays == 0 {
            return 0
        }

        let entries = self.entries.filter { $0.date < date }
        let remaining = self.budget.budget - entries.totalCalories
        let budget = remaining / remainingDays
        return budget
    }

    /// Calculate the consumed calories for a given day.
    /// - Parameter date: The date for which to calculate.
    /// - Returns: The consumed calories for the day.
    func calcDailyConsumed(for date: Date) throws -> Int {
        try self.validateDate(date)
        return self.entries.filter { $0.date == date }.totalCalories
    }

    /// Calculate the remaining calories for a given day.
    /// - Parameter date: The date up to which to calculate.
    /// - Returns: The remaining calories for the day.
    func calcDailyRemaining(for date: Date) throws -> Int {
        try self.validateDate(date)
        let budget = try self.calcDailyBudget(for: date)
        let consumed = try self.calcDailyConsumed(for: date)
        return budget - consumed
    }

    private func validateDate(_ date: Date) throws {
        if !date.isBetween(self.start, self.end) {
            throw CalorieStatisticsError.invalidDate(
                providedDate: date, cycle: (self.start, self.end))
        }
    }
}

enum CalorieStatisticsError: Error {
    case invalidDate(
        String = "Date is outside of the budget cycle.", providedDate: Date,
        cycle: (start: Date, end: Date))
}
