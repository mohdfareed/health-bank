import Foundation
import OSLog
import SwiftData

// TODO: create a units system that let's the user define a unit type by
// defining an enum of possible units and a base unit.
// The system will depend on a service that will implement the conversion
// between all units and the base unit for each type.

// MARK: Statistical Data

/// A data point made up of 2 data values. Allows 2D operations.
protocol DataPoint<X, Y>: CustomStringConvertible {
    associatedtype X
    associatedtype Y

    var x: X { get }
    var y: Y { get }
}

/// A data point default implementation.
struct ValuePoint<X, Y>: DataPoint {
    var x: X
    var y: Y
}

// MARK: Extensions

extension DataPoint {
    var description: String {
        return String(describing: self)
    }
}

extension PersistentModel {
    var description: String {
        return String(describing: self)
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
