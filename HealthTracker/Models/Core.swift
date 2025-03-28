import Foundation
import OSLog
import SwiftData

// MARK: Data

/// The supported sources of data.
enum DataSource {
    case HealthKit
    case CoreData
}

/// A data model. All models which interact with the app's data store
/// conform to this protocol.
protocol DataModel {
    /// The source of the data.
    var source: DataSource { get }
}

// MARK: Plotting Data

/// A data point made up of 2 data values. Allows 2D operations.
protocol DataPoint<X, Y> {
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

// MARK: Errors

enum DataError: Error {
    case InvalidData(String)
    case InvalidDateRange(from: Date, to: Date)
    case InvalidModel(String)
    case DataTypeMismatch(expected: String, actual: String)
}

enum DatabaseError: Error {
    case InitializationError(String, Error? = nil)
    case readError(String, Error? = nil)
    case writeError(String, Error? = nil)
}

enum HealthKitError: Error {
    case authorizationFailed(String, Error? = nil)
    case unsupportedFeature(String)
    case DataTypeMismatch(expected: String, actual: String)
    case readError(String, Error? = nil)
    case writeError(String, Error? = nil)
}
