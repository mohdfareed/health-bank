import Foundation

extension Date {
    /// The time bin unit component.
    func advanced(
        by count: Int, unit: Calendar.Component, using calendar: Calendar = .current
    ) -> Date {
        return calendar.date(byAdding: unit, value: count, to: self)!
    }

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

extension Collection where Element: DataEntry {
    /// Bin the data points using the date by a specific unit.
    func bin(
        step: Int, anchor: Element.X? = nil,
        unit: Calendar.Component, calendar: Calendar = .current
    ) -> [(Range<Element.X>, values: [Element.Y])] {
        let advancer: Advancer<Element.X> = {
            calendar.date(byAdding: unit, value: Int($1), to: $0)!
        }
        return self.bin(step: Date.Stride(step), anchor: anchor, using: advancer)
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
