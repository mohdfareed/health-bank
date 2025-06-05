import Foundation

// MARK: Data Points
// ============================================================================

extension Sequence {
    /// Create data points from a sequence of elements.
    func points<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return map { $0[keyPath: keyPath] }
    }

    /// Create data points from a sequence of elements.
    func points<X, Y>(
        x: KeyPath<Element, X>, y: KeyPath<Element, Y>
    ) -> [(x: X, y: Y)] { map { ($0[keyPath: x], $0[keyPath: y]) } }
}

// MARK: Statistics
// ============================================================================

extension Sequence where Element: AdditiveArithmetic {
    /// The sum of all data points.
    func sum() -> Element { self.reduce(.zero, +) }
}

extension Sequence where Element: AdditiveArithmetic & DurationProtocol {
    /// The average of all data points.
    func average() -> Element? {
        guard self.first(where: { _ in true }) != nil else { return nil }
        let count = self.count(where: { _ in true })
        return self.sum() / count
    }
}

// MARK: Time
// ============================================================================

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
