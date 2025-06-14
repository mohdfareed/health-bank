import Foundation

// MARK: Analytics Service
// ============================================================================

public struct AnalyticsService {
    /// Calculates a running average for a set of date-value pairs.
    /// - Parameters:
    ///   - data: A dictionary of `[Date: Double]` representing the time series data.
    ///   - windowSize: The number of data points to include in each average calculation (e.g., 7 for a 7-day average).
    ///   - unit: The calendar unit that defines the spacing of the data points (e.g., `.day`).
    /// - Returns: A dictionary `[Date: Double]` where the value is the running average ending on that date.
    public func calculateRunningAverage(
        data: [Date: Double], windowSize: Int,
        unit: Calendar.Component, calendar: Calendar = .current
    ) throws -> [Date: Double] {
        guard windowSize > 0 else {
            throw AppError.analytics("Window size must be greater than zero.")
        }

        let sortedDates = data.keys.sorted()
        guard !sortedDates.isEmpty else { return [:] }

        var runningAverages: [Date: Double] = [:]
        var currentWindow: [Double] = []

        // Iterate through all possible dates in the range to ensure consistent windowing
        // This assumes data might be sparse.
        var currentDate = sortedDates.first!
        let endDate = sortedDates.last!

        while currentDate <= endDate {
            if let value = data[currentDate] {
                currentWindow.append(value)
            }

            if currentWindow.count > windowSize {
                currentWindow.removeFirst()
            }

            if !currentWindow.isEmpty {
                runningAverages[currentDate] =
                    currentWindow.reduce(0, +) / Double(currentWindow.count)
            }

            currentDate = calendar.date(
                byAdding: unit, value: 1, to: currentDate
            )!
        }
        return runningAverages
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

    /// The date of the next occurrence of a specific weekday.
    func next(_ weekday: Int, using calendar: Calendar = .current) -> Date {
        let weekday = weekday % 7  // Ensure it's within 0...6 if needed
        let todayWeekday = calendar.component(.weekday, from: self)

        var daysToAdd = weekday - todayWeekday
        if daysToAdd <= 0 {
            daysToAdd += 7
        }
        return calendar.date(byAdding: .day, value: daysToAdd, to: self)!
    }
}
