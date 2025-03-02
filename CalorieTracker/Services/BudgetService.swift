import Foundation
import SwiftData

/// Budget service that manages budget cycles.
struct CalorieBudgetService {
    internal let logger = AppLogger.new(category: "\(CalorieBudgetService.self)")
    private let context: ModelContext

    static var defaultBudget: CalorieBudget {
        CalorieBudget(17_500, lasts: 7, starting: Date.now, named: "Weekly Budget")
    }

    init(_ context: ModelContext) {
        self.context = context
        self.logger.debug("Calorie budget service initialized.")
    }

    /// Create a budget query fetch descriptor.
    /// - Parameter name: The name of the budget.
    /// - Returns: The budget query.
    static func query(_ name: String? = nil) -> FetchDescriptor<CalorieBudget> {
        let defaultName = CalorieBudgetService.defaultBudget.name
        let budgetName = name ?? defaultName

        let budget = FetchDescriptor<CalorieBudget>(
            predicate: #Predicate { $0.name == budgetName }
        )
        return budget
    }

    /// Get a calorie budget. Creates a new budget if it does not exist.
    /// - Parameter name: The name of the budget.
    /// - Returns: The budget cycle.
    func get(_ name: String? = nil) throws -> CalorieBudget {
        let defaultBudget = CalorieBudgetService.defaultBudget
        self.logger.debug("Retrieving budget: \(defaultBudget.name)")
        let budget = CalorieBudgetService.query(name)

        do {
            let results: [CalorieBudget] = try self.context.fetch(budget)
            if let budget = results.first {
                return budget
            }
        } catch {
            throw CalorieBudgetError.databaseError(dbError: error)
        }

        self.logger.info("Budget not found, creating default: \(defaultBudget.name)")
        self.create(defaultBudget)
        return defaultBudget
    }

    /// Create a new budget.
    /// - Parameter budget: The budget to create.
    func create(_ budget: CalorieBudget) {
        self.logger.debug("Creating budget: \(budget.name, privacy: .public)")
        self.context.insert(budget)
    }

    /// Remove a budget.
    /// - Parameter budget: The budget to remove.
    func remove(_ budget: CalorieBudget) {
        self.logger.debug("Removing budget: \(budget.name, privacy: .public)")
        self.context.delete(budget)
    }

    /// Update a budget.
    /// - Parameter budget: The budget to update.
    func update(_ budget: CalorieBudget) {
        self.logger.debug("Updating budget: \(budget.name, privacy: .public)")
        if let existing = self.context.model(for: budget.id) as? CalorieBudget {
            self.context.delete(existing)
        }
        self.context.insert(budget)
    }
}

// MARK: Extensions

extension CalorieBudget {
    /// Calculate the number of days elapsed in the current cycle.
    /// - Parameter date: The reference date, defaults to the current date.
    /// - Returns: The number of days elapsed.
    func calcElapsedDays(for date: Date? = nil) -> Int {
        let refDate = date ?? Date.now
        let (start, _) = self.calcBounds()
        let elapsed = start.days(to: refDate)
        return elapsed
    }

    /// Calculate the number of days remaining in the cycle.
    /// - Parameter date: The reference date, defaults to the current date.
    /// - Returns: The number of days remaining.
    func calcRemainingDays(for date: Date? = nil) -> Int {
        let refDate = date ?? Date.now
        let (_, end) = self.calcBounds()
        let remaining = refDate.days(to: end)
        return remaining
    }

    /// Calculates the start and end dates of a budget cycle, defaulting to the
    /// current cycle by referencing the current date.
    /// - Parameter date: The reference date, defaults to the current date.
    /// - Returns: A tuple containing the start and end dates.
    func calcBounds(for date: Date? = nil) -> (start: Date, end: Date) {
        let refDate = date ?? Date.now

        var (start, _) = self.startDate.calcBounds()
        var end: Date = start.adding(days: self.period)
        let period: Int = refDate > start ? self.period : -self.period

        while !refDate.isBetween(start, end) {
            start = start.adding(days: period)
            end = end.adding(days: period)
        }
        return (start, end)
    }
}

extension Date {
    /// The difference in days between two dates.
    /// - Parameter date: The date to compare.
    /// - Returns: The difference in days.
    func days(to date: Date) -> Int {
        let calendar: Calendar = Calendar.current
        let components: DateComponents
        if self > date {
            components = calendar.dateComponents([.day], from: date, to: self)
        } else {
            components = calendar.dateComponents([.day], from: self, to: date)
        }
        return components.day! + 1  // Inclusive
    }

    /// Get the date after a number of days.
    /// - Parameter days: The number of days to add.
    /// - Returns: The new date.
    func adding(days: Int) -> Date {
        let date = Calendar.current.date(byAdding: .day, value: days, to: self)!
        return date
    }

    /// Whether the date is between two other dates.
    /// - Parameters:
    ///   - start: The start date.
    ///   - end: The end date.
    /// - Returns: `true` if the date is between the two dates; otherwise, `false`.
    func isBetween(_ start: Date, _ end: Date) -> Bool {
        if start > end {
            return self >= end && self <= start
        }
        return self >= start && self <= end
    }

    /// Get the start and end of the day.
    /// - Returns: A tuple containing the start and end of the day.
    func calcBounds() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: self)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        return (start, end)
    }
}
