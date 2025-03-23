import Foundation
import OSLog
import SwiftData

// TODO: create a units system that let's the user define a unit type by
// defining an enum of possible units and a base unit.
// The system will depend on a service that will implement the conversion
// between all units and the base unit for each type.

// MARK: Statistical Data

/// A statistical data point value.
// This is the base of all statistically operable data.
typealias DataValue = Strideable & Comparable

/// A data point made up of 2 data values. Allows 2D operations.
protocol DataPoint<X, Y>: CustomStringConvertible {
    associatedtype X: DataValue
    associatedtype Y: DataValue

    var x: X { get }
    var y: Y { get }
}

/// A data point default implementation.
struct ValuePoint<X: DataValue, Y: DataValue>: DataPoint {
    var x: X
    var y: Y
}

// MARK: Data Entries

typealias DataEntries<T: DataValue> = [any DataEntry<T>]

/// A timed data entry. This is the base of all stored health data.
protocol DataEntry<T>: CustomStringConvertible {
    associatedtype T: DataValue
    /// The date the entry was created.
    var date: Date { get }
    /// The data point.
    var value: T { get }
}

/// A data entry with a value. This is a default implementation.
struct ValueEntry<T: DataValue>: DataEntry {
    var date: Date
    var value: T
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

    /// Generate a new data entry based on the current one.
    func asEntry<T: DataValue>(_ value: T) -> any DataEntry<T> {
        return ValueEntry(date: self.date, value: value)
    }
}

// MARK: Errors

enum DatabaseError: Error {
    case InitializationError(String, Error? = nil)
    case queryError(String, Error? = nil)
}

enum DataError: Error {
    case InvalidData(String)
    case InvalidDateRange(from: Date, to: Date)
}

enum HealthKitError: Error {
    case authorizationFailed(String, Error? = nil)
    case unsupportedFeature(String)
    case DataTypeMismatch(expected: String, actual: String)
    case queryError(String, Error? = nil)
}
