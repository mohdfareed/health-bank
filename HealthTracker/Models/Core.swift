import Foundation
import OSLog
import SwiftData

// TODO: create a units system that let's the user define a unit type by
// defining an enum of possible units and a base unit.
// The system will depend on a service that will implement the conversion
// between all units and the base unit for each type.

// MARK: Statistical Data

/// A statistical data point value. This is the base of all statistically operable data.
typealias DataValue = Strideable & Comparable

/// A data point made up of 2 data values. Allows 2D operations.
protocol DataPoint<X, Y>: CustomStringConvertible {
    associatedtype X: DataValue
    associatedtype Y: DataValue

    var x: X { get }
    var y: Y { get }
}

/// A data point with a value. This is a default implementation.
struct ValuePoint<X: DataValue, Y: DataValue>: DataPoint {
    var x: X
    var y: Y

    init(x: X, y: Y) {
        self.x = x
        self.y = y
    }
}

// MARK: Data Entries

/// The possible date entry sources. This maps to the data store of the entry.
enum DataSource: String {
    case manual
    case healthKit
}

/// A timed data entry. This is the base of all stored health data.
protocol DataEntry<T>: CustomStringConvertible {
    associatedtype T: DataValue

    /// The source of the entry.
    var source: DataSource { get }
    /// The date the entry was created.
    var date: Date { get }
    /// The data point.
    var value: T { get }
}

/// A data entry with a value. This is a default implementation.
struct ValueEntry<T: DataValue>: DataEntry {
    var source: DataSource
    var date: Date
    var value: T

    init(_ value: T, on date: Date, from source: DataSource) {
        self.source = source
        self.date = date
        self.value = value
    }
}

// MARK: Extensions

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
        return ValueEntry(value, on: self.date, from: self.source)
    }
}

extension Collection where Element: DataPoint {
    /// The x-axis data points.
    var xAxis: [Element.X] { self.map { $0.x } }
    /// The y-axis data points.
    var yAxis: [Element.Y] { self.map { $0.y } }
}

extension Collection where Element: DataEntry {
    /// The data points of the entries.
    var dataPoints: [any DataPoint<Date, Element.T>] {
        return self.map({ $0.dataPoint })
    }
}

// MARK: Errors

enum DatabaseError: Error {
    case queryError(_ message: String, dbError: Error? = nil)
}

enum DataError: Error {
    case InvalidData(_ message: String)
    case InvalidDateRange(from: Date, to: Date)
}

enum HealthKitError: Error {
    case authorizationFailed(String, Error? = nil)
    case unsupportedQuery(String)
}
