import Foundation

extension DataPoint {
    var description: String {
        return String(describing: self)
    }
}

extension DataEntry {
    var description: String {
        return String(describing: self)
    }

    /// Convert the entry to a data point.
    var dataPoint: any DataPoint<Date, T> {
        return ValuePoint(x: self.date, y: self.value)
    }

    /// Generate a new data entry based on the current one.
    func asEntry<T: DataValue>(_ value: T) -> any DataEntry<T> {
        return ValueEntry(value, on: self.date)
    }
}

extension Collection where Element: DataPoint {
    /// The x-axis data points.
    var xAxis: any Collection<Element.X> { self.map { $0.x } }
    /// The y-axis data points.
    var yAxis: any Collection<Element.Y> { self.map { $0.y } }
}

extension Collection where Element: DataEntry {
    /// The data points of the entries.
    var dataPoints: any Collection<any DataPoint<Date, Element.T>> {
        return self.map({ $0.dataPoint })
    }
}
