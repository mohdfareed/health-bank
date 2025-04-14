import Foundation

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
