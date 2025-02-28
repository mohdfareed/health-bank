import Foundation

extension Date {
    /// The day of the week for the date.
    var weekday: WeeklyBudget.Weekday {
        return WeeklyBudget.Weekday(rawValue: Calendar.current.component(.weekday, from: self))!
    }
}

extension WeeklyBudget {
    /// The number of days passed in the cycle.
    var cycleDays: Int {
        let todayValue = Date().weekday.rawValue
        let resetValue = resetDay.rawValue
        return (todayValue - resetValue + 7) % 7
    }

    /// The number of days left in the cycle.
    var remainingDays: Int {
        return 7 - cycleDays
    }

    /// The date when the budget will reset.
    var resetDate: Date {
        let calendar: Calendar = Calendar.current
        let resetDate: Date = calendar.date(byAdding: .day, value: self.remainingDays, to: Date())!
        return calendar.startOfDay(for: resetDate)
    }

    /// The date when the budget was last reset.
    var lastResetDate: Date {
        let calendar: Calendar = Calendar.current
        let lastResetDate: Date = calendar.date(byAdding: .day, value: -self.cycleDays, to: Date())!
        return calendar.startOfDay(for: lastResetDate)
    }

    /// Calculate the calories consumed for the current cycle.
    func consumedCalories(for entries: [CalorieEntry]) -> Int {
        let entries: [CalorieEntry] = entries.filter { $0.date >= self.lastResetDate }
        let consumed: Int = entries.reduce(0) { $0 + $1.calories }
        return consumed
    }

    /// Calculate the remaining calories for the current cycle.
    func remainingCalories(for entries: [CalorieEntry]) -> Int {
        return self.budget - self.consumedCalories(for: entries)
    }

    /// Calculate the remaining calories for today.
    func remainingDailyCalories(for entries: [CalorieEntry]) -> Int {
        let remaining: Int = self.remainingCalories(for: entries)
        return remaining / self.remainingDays
    }
}
