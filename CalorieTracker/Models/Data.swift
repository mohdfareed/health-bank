import Foundation
import SwiftData

// TODO: create a units system that let's the user define a unit type by
// defining an enum of possible units and a base unit.
// The system will depend on a service that will implement the conversion
// between all units and the base unit for each type.

// MARK: Data Entries

/// The possible date entry sources.
enum DataSource: String {
    case manual
    case healthKit
}

/// A timed data entry.
protocol DataEntry: CustomStringConvertible {
    /// The source of the entry.
    var source: DataSource { get }
    /// The date the entry was created.
    var date: Date { get }
    /// The data point.
    var value: Double { get }
}

/// A data entry with a value.
private struct ValueEntry: DataEntry {
    var source: DataSource
    var date: Date
    var value: Double

    init(_ value: Double, on date: Date, from source: DataSource) {
        self.source = source
        self.date = date
        self.value = value
    }
}

// MARK: Extensions

extension DataEntry {
    var description: String {
        return String(describing: self)
    }

    /// Convert the entry to a value entry with a custom value.
    func asEntry(_ value: Double) -> DataEntry {
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
