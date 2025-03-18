import Foundation
import SwiftData

// MARK: Data Types

/// Statistical data points.
typealias DataPoints = [Double]

/// The possible date entry sources.
enum DataSource: String {
    case manual
    case healthKit
}

/// A tracked data entry.
protocol DataEntry: CustomStringConvertible {
    /// The date the entry was created.
    var date: Date { get }
    /// The source of the entry.
    var source: DataSource { get }
}

// MARK: Extensions

extension DataEntry {
    var description: String {
        return String(describing: self)
    }
}

extension [DataEntry] {
    var datePoints: [Date] {
        return self.map { $0.date }
    }
}

// MARK: Errors

enum DatabaseError: Error {
    case queryError(_ message: String, dbError: Error? = nil)
}

enum DataError: Error {
    case InvalidDateRange(from: Date, to: Date)
}

enum HealthKitStoreError: Error {
    case authorizationFailed(Error, Error.Type)
    case unsupportedQuery(String)
}
