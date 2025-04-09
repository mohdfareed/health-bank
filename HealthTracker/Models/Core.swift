import Foundation
import OSLog
import SwiftData

// MARK: Data Store

/// The supported sources of data.
enum DataSource: Codable {
    /// The persistent data store.
    case local
    /// A temporary data store.
    case memory
    /// The HealthKit store.
    case healthKit
}

/// A protocol for data models that originate from a data source.
protocol DataRecord: PersistentModel {
    /// The unique identifier of the data.
    var id: UUID { get }
    /// The source of the data.
    var source: DataSource { get }
}

// MARK: Plotting

/// A data point made up of 2 data values. Allows 2D operations.
protocol DataPoint<X, Y> {
    associatedtype X
    associatedtype Y
    var x: X { get }
    var y: Y { get }
}

/// A data point default implementation.
struct GenericPoint<X, Y>: DataPoint {
    var x: X
    var y: Y
}

// MARK: Settings

/// A protocol for models with an ID trackable in the `UserDefaults` database.
protocol Singleton: PersistentModel where ID == UUID {}

/// A protocol to define the raw value stored in the `UserDefaults` database.
/// It mirrors the `AppStorage` interface and **must not be implemented**.
/// It is implemented internally by the supported types.
internal protocol SettingsValue: Sendable {}

/// A key for a settings value stored in the `UserDefaults` database.
struct Settings<Value: SettingsValue>: Sendable {
    /// The unique key for the value in `UserDefaults`.
    let id: String
    /// The default value for the setting.
    let `default`: Value
}

extension Settings {
    init(_ id: String, default: Value) {
        self.id = id
        self.default = `default`
    }
    init(_ id: String, default: Value = nil)
    where Value: ExpressibleByNilLiteral {
        self.id = id
        self.default = `default`
    }
}
