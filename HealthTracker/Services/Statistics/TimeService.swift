import Foundation

extension Collection where Element: DataPoint<Date, Element.Y> {
    /// Bin the data points using the date by a specific unit.
    func bin(
        step: Int, anchor: Date? = nil,
        unit: Calendar.Component, calendar: Calendar = .current
    ) -> [(Range<Date>, values: [Element.Y])] {
        let advancer: Advancer<Date> = {
            calendar.date(byAdding: unit, value: Int($1), to: $0)!
        }

        return self.bin(
            step: Date.Stride(step), anchor: anchor, using: advancer
        )
    }
}

extension Date {
    /// Floors the date to the beginning of a specific bin unit.
    func floored(to unit: Calendar.Component, using calendar: Calendar = .current) -> Date {
        switch unit {
        case .second:
            return calendar.date(
                from: calendar.dateComponents(
                    [.year, .month, .day, .hour, .minute, .second], from: self)
            )!
        case .minute:
            return calendar.date(
                from: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
            )!
        case .hour:
            return calendar.date(
                from: calendar.dateComponents([.year, .month, .day, .hour], from: self)
            )!
        case .day:
            return calendar.startOfDay(for: self)
        case .weekday:
            return calendar.date(
                from: calendar.dateComponents([.year, .month, .weekday], from: self)
            )!
        case .weekOfYear:
            return calendar.date(
                from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
            )!
        case .month:
            return calendar.date(
                from: calendar.dateComponents([.year, .month], from: self)
            )!
        case .year:
            return calendar.date(
                from: calendar.dateComponents([.year], from: self)
            )!
        default:
            return self
        }
    }
}

// extension Date {
//     /// The date bin of the current week.
//     func bin(starting startOfWeek: Weekday, weeks: UInt = 1) -> DateInterval {
//         let calendar = Calendar.current
//         let weekday = calendar.component(.weekday, from: self)
//
//         let elapsedDays = (weekday - startOfWeek.rawValue + 7) % 7
//         let start = calendar.startOfDay(
//             for: calendar.date(byAdding: .day, value: -elapsedDays, to: self)!
//         )
//
//         let end = calendar.date(byAdding: .day, value: 7 * Int(weeks), to: start)!
//         return DateInterval(start: start, end: end)
//     }
// }
