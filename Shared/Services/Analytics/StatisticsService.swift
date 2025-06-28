import Foundation

// MARK: Time Series
// ============================================================================

extension [Date: Double] {
    /// Bucket the data by a specific time unit.
    func bucketed(
        by unit: Calendar.Component, using calendar: Calendar
    ) -> [Date: [Double]] {
        var buckets = [Date: [Double]]()
        for (date, value) in self {
            let flooredDate = date.floored(to: unit, using: calendar) ?? date
            buckets[flooredDate, default: []].append(value)
        }
        return buckets
    }

    /// The data points in the time series, sorted by date.
    var points: [Double] {
        self
            .sorted { $0.key < $1.key }  // Sort by date
            .map { $0.value }  // Extract values
    }
}

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

extension Sequence where Element: BinaryFloatingPoint {
    /// The average of all data points.
    func average() -> Element? {
        guard self.first(where: { _ in true }) != nil else { return nil }
        let count = self.count(where: { _ in true })
        return self.sum() / Element(count)
    }
}

extension Double {
    static func / (lhs: Double, rhs: Int) -> Double {
        return lhs / Double(rhs)
    }
}
extension Int {
    static func / (lhs: Int, rhs: Double) -> Double {
        return Double(lhs) / rhs
    }
}

// MARK: Time
// ============================================================================

extension Date {
    /// Add an amount of a calendar component.
    func adding(
        _ value: Int, _ component: Calendar.Component, using calendar: Calendar
    ) -> Date? {
        calendar.date(byAdding: component, value: value, to: self)
    }

    /// Floor: the start of the unit.
    func floored(to unit: Calendar.Component, using cal: Calendar) -> Date? {
        interval(of: unit, using: cal)?.start
    }

    /// Ceiling: the last instant of the unit.
    func ceiled(to unit: Calendar.Component, using cal: Calendar) -> Date? {
        guard let interval = interval(of: unit, using: cal) else { return nil }
        return interval.end.adding(-1, .nanosecond, using: cal)
    }

    /// A date range ending at the unit’s ceiling and
    /// going back `duration` units.
    func dateRange(
        by duration: UInt = 1, _ unit: Calendar.Component = .day,
        using cal: Calendar
    ) -> (from: Date, to: Date)? {
        guard
            let end = ceiled(to: unit, using: cal),
            let start = end.adding(-Int(duration), unit, using: cal)
        else { return nil }
        return (start, end)
    }

    /// Distance in whole units.
    func distance(
        to other: Date, in unit: Calendar.Component,
        using cal: Calendar
    ) -> Int? {
        cal.dateComponents([unit], from: self, to: other)
            .value(for: unit)
    }

    /// Next weekday occurrence.
    func next(_ weekday: Int, using cal: Calendar) -> Date? {
        let components = cal.dateComponents(
            [.year, .month, .day, .weekday], from: self
        )

        let today = components.weekday!
        let offset = (weekday - today + 7) % 7
        return cal.date(
            byAdding: .day, value: offset == 0 ? 7 : offset, to: self
        )
    }

    private func interval(
        of unit: Calendar.Component, using cal: Calendar
    ) -> DateInterval? {
        cal.dateInterval(of: unit, for: self)
    }
}
