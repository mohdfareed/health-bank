import Foundation
import SwiftData

/// An application error.
enum AppError: Error {
    /// An error that occurred during the app's execution.
    case runtimeError(String, Error? = nil)  // REVIEW: Add more cases.
}

// MARK: Utilities
// ============================================================================

/// A protocol for models with an ID trackable in the `UserDefaults` database.
/// The ID can be attributed with `.unique` with `UUID.zero` as the default
/// to guarantee a single instance of the model in the database. The singleton
/// must provide a default value through the `init()` method.
protocol Singleton: PersistentModel where ID == UUID {
    /// The ID of the model. The first instance of a model with this ID,
    /// according to a sort order, is considered the singleton.
    var id: ID { get set }
    init()
}

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
