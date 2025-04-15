import Combine
import Foundation
import OSLog
import SwiftData
import SwiftUI

// MARK: Data Models
// ============================================================================

/// The supported sources of data.
enum DataSource: Codable, CaseIterable {
    case local, healthKit, simulation
    init() { self = .local }
}

/// A protocol for data models that originate from a data source.
protocol DataRecord: PersistentModel {
    /// The source of the data.
    var source: DataSource { get set }
}

// MARK: Remote Data Models
// ============================================================================

/// A protocol for data records that can be queried from remote sources.
/// Models must be equatable to determine updates.
protocol RemoteRecord: DataRecord {
    /// The model's remote sources query.
    associatedtype Query: RemoteQuery<Self>
}

/// A protocol for the query that can be performed on a data record.
protocol RemoteQuery<Model> {
    /// The type of the data queried.
    associatedtype Model: RemoteRecord
}

// MARK: Remote Data Stores
// ============================================================================

/// A protocol for remote data records stores.
/// The store queries a remote store for remote data and optional backups of
/// local data. A store is the provider of all non-local data it returns.
/// Remote stores **must** be used through the `RemoteContext`
protocol RemoteStore {
    /// Fetch the data from the store.
    /// The store must correctly assign the source to the data.
    func fetch<M, Q>(_ query: Q) throws -> [M] where Q: RemoteQuery<M>
    /// Add or update a local data backup in the store.
    func save(_ model: any DataRecord) throws
    /// Remove a local data backup from the store.
    func delete(_ model: any DataRecord) throws
}

// MARK: Utilities
// ============================================================================

/// A protocol for models with an ID trackable in the `UserDefaults` database.
/// The ID can be attributed with `.unique` with `UUID.zero` as the default
/// to guarantee a single instance of the model in the database.
protocol Singleton: PersistentModel where ID == UUID {}

// MARK: Settings
// ============================================================================

/// A protocol to define the raw value stored in the `UserDefaults` database.
/// It mirrors the `AppStorage` interface and **must not be implemented**.
/// It is implemented internally by the supported types.
internal protocol SettingsValue: Sendable {}

/// A protocol to define a settings value that can be stored as a string.
/// New settings value types can be created by implementing this protocol.
typealias StringSettingsValue = SettingsValue & RawRepresentable<String>
/// A protocol to define a settings value that can be stored as an integer.
/// New settings value types can be created by implementing this protocol.
typealias IntSettingsValue = SettingsValue & RawRepresentable<Int>

/// A key for a settings value stored in the `UserDefaults` database.
/// It must be sendable to allow the key to be reused throughout the app.
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
