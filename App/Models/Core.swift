import Foundation
import SwiftData

/// An application error.
enum AppError: Error {
    /// An error related to HealthKit operations.
    case healthKit(HealthKitError)
    /// An error related to data storage operations (e.g., SwiftData).
    case storage(StorageError)
    /// An error related to unit conversion or localization.
    case localization(String, underlyingError: Error? = nil)
    /// A generic runtime error with a descriptive message.
    case runtimeError(String, underlyingError: Error? = nil)
}

/// Specific errors related to HealthKit operations.
enum HealthKitError: Error {
    case queryFailed(Error, String? = nil)
    case saveFailed(Error, String? = nil)
    case deleteFailed(Error, String? = nil)
    case authorizationFailed(Error)
    case unexpectedError(String)
}

/// Specific errors related to data storage operations (e.g., SwiftData).
enum StorageError: Error {
    case fetchFailed(Error, String? = nil)  // E.g., "Failed to fetch X model"
    case saveFailed(Error, String? = nil)  // E.g., "Failed to save X model"
    case deleteFailed(Error, String? = nil)  // E.g., "Failed to delete X model"
    case modelNotFound(String)  // E.g., "Model X with ID Y not found"
}

// MARK: Singleton
// ============================================================================

/// A protocol for models with an ID trackable in the `UserDefaults` database.
/// The ID can be attributed with `.unique` with `UUID.zero` as the default
/// to guarantee a single instance of the model in the database. The singleton
/// must provide a default value through the `init()` method.
protocol Singleton: PersistentModel {
    /// The ID of the model. The first instance of a model with this ID,
    /// according to a sort order, is considered the singleton.
    var singletonID: String { get set }
    init()
}

// MARK: Units System
// ============================================================================

/// The unit localization definition.
struct UnitDefinition<D: Dimension> {
    /// The unit formatting usage.
    let usage: MeasurementFormatUnitUsage<D>
    /// The display unit to use if not localized.
    let baseUnit: D
    /// The alternative units allowed for the unit.
    let altUnits: [D]

    init(
        _ unit: D = .baseUnit(), alts: [D] = [],
        usage: MeasurementFormatUnitUsage<D> = .general
    ) {
        self.baseUnit = unit
        self.altUnits = alts
        self.usage = usage
    }
}

// MARK: Settings System
// ============================================================================

/// A protocol to define the raw value stored in the `UserDefaults` database.
/// It an be implemented with `String` or `Int` to support enumeration types.
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

/// A type-erased settings key.
struct AnySettings: Sendable {
    let id: String
    let `default`: SettingsValue
    init<Value>(_ key: Settings<Value>) where Value: SettingsValue {
        self.id = key.id
        self.default = key.default
    }
}
