import Foundation

// MARK: Statistics
// ============================================================================

typealias Advancer<T: Strideable> = (T, T.Stride) -> T

extension Sequence {
    func points<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return map { $0[keyPath: keyPath] }
    }

    func points<X, Y>(
        x: KeyPath<Element, X>, y: KeyPath<Element, Y>
    ) -> [(x: X, y: Y)] {
        return map { ($0[keyPath: x], $0[keyPath: y]) }
    }
}

extension Sequence where Element: AdditiveArithmetic {
    /// The sum of all data points.
    func sum() -> Element {
        self.reduce(.zero, +)
    }
}

extension Sequence where Element: AdditiveArithmetic & DurationProtocol {
    /// The average of all data points.
    func average() -> Element? {
        guard self.first(where: { _ in true }) != nil else {
            return nil
        }
        let count = self.count(where: { _ in true })
        return self.sum() / count
    }
}

// MARK: Time
// ============================================================================

extension UnitDuration {
    // FIXME: Correct set `.wide` width to "days".
    class var days: UnitDuration {
        return UnitDuration(
            symbol: "d",  // 1d = 60s * 60m * 24h
            converter: UnitConverterLinear(coefficient: 60 * 60 * 24)
        )
    }
}

extension Date {
    /// Get the difference between two dates in a unit.
    func distance(
        to date: Date, in unit: Calendar.Component,
        using calendar: Calendar = .current
    ) -> Int? {
        let dateComponents = calendar.dateComponents(
            [unit], from: self, to: date
        )
        return dateComponents.value(for: unit)
    }

    /// Add an amount of a calendar component.
    func adding(
        _ value: Int, _ component: Calendar.Component,
        using calendar: Calendar = .current
    ) -> Date {
        calendar.date(byAdding: component, value: value, to: self)!
    }

    /// Floors the date to the beginning of a specific time unit.
    func floored(
        to unit: Calendar.Component, using calendar: Calendar = .current
    ) -> Date {
        if let interval = calendar.dateInterval(of: unit, for: self) {
            return interval.start
        }
        return self
    }
}

// MARK: Budget
// ============================================================================

/// A generated budget report performed on a collection of data.
struct BudgetReport<T: DurationProtocol> {
    /// The allocated budget amount.
    let budget: T
    /// The total amount of of the budget consumed.
    let consumed: T
    /// The remaining amount of the budget.
    var remaining: T
    /// The progress of the budget. It is a value between 0 and 1.
    var progress: T

    init(_ budget: T, on entries: any Collection<T>) throws
    where T: BinaryFloatingPoint {
        guard budget.magnitude > T.zero.magnitude else {
            throw DataError.InvalidData("Budget must be greater than 0.")
        }

        self.budget = budget
        self.consumed = entries.sum()
        self.remaining = budget - consumed
        self.progress = consumed / budget
    }
}

// MARK: Errors
// ============================================================================

enum DataError: Error {
    case InvalidData(String)
    case InvalidDateRange(from: Date, to: Date)
    case InvalidModel(String)
    case DataTypeMismatch(expected: String, actual: String)
}
