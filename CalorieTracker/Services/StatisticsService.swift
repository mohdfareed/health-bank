import Foundation

extension DataPoints {
    /// The sum of all data points.
    func sum() -> Double {
        return self.reduce(0, +)
    }

    /// The average of all data points.
    func average() -> Double {
        return Double(self.sum()) / Double(self.count)
    }
}

extension Date {
    /// The number of days between two dates.
    func days(to date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: date)
        return components.day ?? 0
    }

    /// The date added by a number of days.
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }

    /// A date interval of a number of minutes, starting from the beginning of this minute.
    func minutesPeriod(of minutes: UInt = 1) -> DateInterval {
        let calendar = Calendar.current
        let minute = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)

        let start = calendar.date(from: minute)!
        let end = calendar.date(byAdding: .minute, value: Int(minutes), to: start)!
        return DateInterval(start: start, end: end)
    }

    /// A date interval of a number of hours, starting from the beginning of this hour.
    func hourlyPeriod(of hours: UInt = 1) -> DateInterval {
        let calendar = Calendar.current
        let hour = calendar.dateComponents([.year, .month, .day, .hour], from: self)

        let start = calendar.date(from: hour)!
        let end = calendar.date(byAdding: .hour, value: Int(hours), to: start)!
        return DateInterval(start: start, end: end)
    }

    /// A date interval of a number of days, starting from the beginning of this day.
    func dailyPeriod(of days: UInt = 1) -> DateInterval {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: self)
        let end = calendar.date(byAdding: .day, value: Int(days), to: start)!
        return DateInterval(start: start, end: end)
    }

    /// A date interval of a number of weeks, starting from the beginning of this week.
    func weeklyPeriod(starting startOfWeek: Weekday, of weeks: UInt = 1) -> DateInterval {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)

        let elapsedDays = (weekday - startOfWeek.rawValue + 7) % 7
        let start = calendar.startOfDay(
            for: calendar.date(byAdding: .day, value: -elapsedDays, to: self)!
        )

        let end = calendar.date(byAdding: .day, value: 7 * Int(weeks), to: start)!
        return DateInterval(start: start, end: end)
    }

    /// A date interval of a number of months, starting from the beginning of this month.
    func monthlyPeriod(of months: UInt = 1) -> DateInterval {
        let calendar = Calendar.current
        let start = calendar.date(
            from: calendar.dateComponents([.year, .month], from: self)
        )!

        let end = calendar.date(byAdding: .month, value: Int(months), to: start)!
        return DateInterval(start: start, end: end)
    }
}
