import Foundation
import OSLog
import SwiftData

// TODO: create a units system that let's the user define a unit type by
// defining an enum of possible units and a base unit.
// The system will depend on a service that will implement the conversion
// between all units and the base unit for each type.

// MARK: Statistical Data

typealias DataValue = Strideable & Comparable

protocol DataPoint<X, Y> {
    associatedtype X: DataValue
    associatedtype Y: DataValue

    var x: X { get }
    var y: Y { get }
}

// MARK: Data Entries

/// The possible date entry sources.
enum DataSource: String {
    case manual
    case healthKit
}

/// A timed data entry.
protocol DataEntry<Y>: DataPoint, CustomStringConvertible where X == Date {
    /// The source of the entry.
    var source: DataSource { get }
    /// The date the entry was created.
    var date: Date { get }
    /// The data point.
    var value: Y { get }
}

// MARK: Extensions

/// A data entry with a value.
private struct ValueEntry<T: DataValue>: DataEntry {
    typealias Y = T
    
    var source: DataSource
    var date: Date
    var value: T

    init(_ value: T, on date: Date, from source: DataSource) {
        self.source = source
        self.date = date
        self.value = value
    }
}

extension DataEntry {
    var x: Date { self.date }
    var y: Y { self.value }
    var description: String {
        return String(describing: self)
    }

    /// Convert the entry to a value entry with a custom value.
    func asEntry<T: DataValue>(_ value: T) -> any DataEntry<T> {
        return ValueEntry(value, on: self.date, from: self.source)
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
    case authorizationFailed(Error, Error.Type)
    case unsupportedQuery(String)
}
