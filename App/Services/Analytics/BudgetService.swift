import Foundation

// MARK: Budget Report
// ============================================================================

/// A protocol that defines the requirements for a budget entry.
typealias BudgetEntry = DurationProtocol & BinaryFloatingPoint

/// A generated budget report performed on a collection of data.
struct BudgetReport<T: BudgetEntry> {
    /// The allocated budget amount.
    let budget: T
    /// The total amount of of the budget consumed.
    let consumed: T
    /// The remaining amount of the budget.
    var remaining: T { budget - consumed }
    /// The progress of the budget. It is a value between 0 and 1.
    var progress: T {
        guard budget > T.zero else { return T.zero }
        return consumed / budget
    }

    init(_ budget: T, consumed: T) throws {
        guard budget.magnitude > T.zero.magnitude else {
            throw AnalyticsError.invalidData("Budget must be greater than 0.")
        }

        self.budget = budget
        self.consumed = consumed
    }

    init(_ budget: T, on entries: any Collection<T>) throws {
        try self.init(budget, consumed: entries.sum())
    }
}

// MARK: Budget Modes
// ============================================================================

enum BudgetMode {
    case daily
    case weekly
    case monthly

    var unit: Calendar.Component {
        switch self {
        case .daily: return .day
        case .weekly: return .weekOfYear
        case .monthly: return .month
        }
    }

    var next: Calendar.Component {
        switch self {
        case .daily: return .weekOfYear
        case .weekly: return .month
        case .monthly: return .year
        }
    }
}

// MARK: Budget Service
// ============================================================================

struct BudgetService {
    private let calendar: Calendar

    /// Generates time-based budget reports with dynamic reallocation
    /// - Parameters:
    ///   - total: The budget amount for the period
    ///   - mode: The granularity of budget reports
    ///   - date: A date within the budget period
    ///   - entries: Collection of entries
    ///   - calendar: The calendar to use
    /// - Returns: Dictionary mapping period start dates to budget reports
    func budget<T: BudgetEntry>(
        total: T, mode: BudgetMode, on date: Date,
        entries: [(date: Date, value: T)],
        using calendar: Calendar = .current
    ) throws -> [Date: BudgetReport<T>] {
        guard total.magnitude > T.zero.magnitude else {
            throw AnalyticsError.invalidData("Budget must be greater than 0.")
        }

        // Generate all period dates within the range
        let periodDates = generatePeriodDates(from: date, mode: mode)
        guard !periodDates.isEmpty else {
            throw AnalyticsError.invalidData(
                "No valid periods found in the date range."
            )
        }

        // Group entries by period
        let totalPeriods = T(periodDates.count)
        let entriesByPeriod = groupEntriesByPeriod(
            entries, periods: periodDates, mode: mode
        )

        var budgetReports: [Date: BudgetReport<T>] = [:]
        var remainingBudget = total
        var remainingPeriods = totalPeriods

        // Process each period chronologically
        for periodStart in periodDates.sorted() {
            let periodEntries = entriesByPeriod[periodStart] ?? []
            let consumed = periodEntries.reduce(T.zero) { $0 + $1.value }

            // Calculate current period budget (redistributed from remaining)
            let currentBudget =
                remainingPeriods > T.zero
                ? remainingBudget / remainingPeriods
                : T.zero

            // Create budget report for this period
            let report = try BudgetReport(currentBudget, consumed: consumed)
            budgetReports[periodStart] = report

            // Update remaining budget and periods for next iteration
            remainingBudget -= consumed
            remainingPeriods -= 1
        }

        return budgetReports
    }

}

// MARK: Private Methods
// ============================================================================

extension BudgetService {

    private func generatePeriodDates(
        from startDate: Date, mode: BudgetMode
    ) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate.floored(
            to: mode.unit, using: calendar
        )
        let endDate = currentDate.adding(
            1, mode.next, using: calendar
        ).adding(-1, .second, using: calendar)  // End of the period

        while currentDate <= endDate {
            dates.append(currentDate)
            let nextDate = currentDate.adding(
                1, mode.unit, using: calendar
            )
            currentDate = nextDate
        }
        return dates
    }

    private func groupEntriesByPeriod<T: BudgetEntry>(
        _ entries: [(date: Date, value: T)],
        periods: [Date], mode: BudgetMode
    ) -> [Date: [(date: Date, value: T)]] {
        var grouped: [Date: [(date: Date, value: T)]] = [:]
        for entry in entries {
            if let periodStart = findPeriodStart(
                for: entry.date, in: periods, mode: mode
            ) {
                grouped[periodStart, default: []].append(entry)
            }
        }
        return grouped
    }

    private func findPeriodStart(
        for date: Date, in periods: [Date], mode: BudgetMode
    ) -> Date? {
        return periods.first { periodStart in
            let periodEnd = periodStart.adding(
                1, mode.unit, using: calendar
            )
            return date >= periodStart && date < periodEnd
        }
    }
}
