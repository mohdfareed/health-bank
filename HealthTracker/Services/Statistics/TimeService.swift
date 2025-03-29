import Foundation

extension Collection where Element: DataPoint<Date, Element.Y> {
    /// Bin the data points into the range.
    func bin(
        _ count: Int,
        unit: Calendar.Component, calendar: Calendar = .current
    ) -> [(Range<Element.X>, values: [Element.Y])]
    where Element.X == Date {
        guard
            let min = self.points(\.x).min(),
            let max = self.points(\.x).max(),
            let steps = min.distance(to: max, in: unit, using: calendar)
        else {
            return []
        }

        let step = steps / count
        return self.bin(step: step, unit: unit, calendar: calendar)
    }

    /// Bin the data points using the date by a specific unit.
    func bin(
        step: Int, anchor: Date? = nil,
        unit: Calendar.Component, calendar: Calendar = .current
    ) -> [(Range<Element.X>, values: [Element.Y])]
    where Element.X == Date {
        let advancer: Advancer<Date> = {
            calendar.date(byAdding: unit, value: Int($1), to: $0)!
        }

        return self.bin(
            step: Date.Stride(step), anchor: anchor, using: advancer
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
