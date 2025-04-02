import SwiftData
import SwiftUI

/// A protocol to define a settings model. It is used to define a structure
/// in the `UserDefaults` database. A default initializer is required to define
/// the default values for the settings.
protocol Settings { init() }
/// A protocol to which all app settings value types conform.
protocol SettingsValue: Codable, Sendable {}
/// A type of a key path to a settings value.
typealias SettingsKeyPath<S: Settings, V: SettingsValue> = KeyPath<S, V>

/// A property wrapper to bind a settings value. This will fetch the value on
/// reads and write to the `UserDefaults` on writes.
@propertyWrapper
struct SettingsBinding<Value: SettingsValue>: DynamicProperty, Sendable {
    private let (id, defaultValue): (id: String, default: Value)
    private let storeName: String?
    private var defaults: UserDefaults {
        guard let storeName = self.storeName else {
            return UserDefaults.standard
        }
        return UserDefaults(suiteName: storeName) ?? UserDefaults.standard
    }

    init<S>(_ keyPath: SettingsKeyPath<S, Value>, store: String? = nil) {
        (self.id, self.defaultValue) = keyPath.key
        self.storeName = store
    }

    var wrappedValue: Value {
        get {
            self.defaults.object(forKey: self.id) as? Value ?? self.defaultValue
        }
        nonmutating set { self.defaults.set(newValue, forKey: self.id) }
    }

    var projectedValue: Binding<Value> {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
}
extension Binding { typealias Settings = SettingsBinding }

/// A property wrapper to fetch a settings value. This will fetch the value
/// from the `UserDefaults` on reads and write to the `UserDefaults` on
/// writes. This is a wrapper around `AppStorage`.
@MainActor @propertyWrapper
struct SettingsQuery<Value: SettingsValue>: DynamicProperty, Sendable {
    @AppStorage var storedValue: Value

    init<S>(_ keyPath: SettingsKeyPath<S, Value>, store: UserDefaults? = nil) {
        guard let store = createAppStore(key: keyPath.key, store: store) else {
            fatalError("Failed to create AppStorage for key: \(keyPath.key)")
        }
        self._storedValue = store
    }

    var wrappedValue: Value {
        get { self.storedValue }
        nonmutating set { self.storedValue = newValue }
    }

    var projectedValue: Binding<Value> {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
}
extension Query { typealias Settings = SettingsQuery }

// MARK: Extensions

private typealias SettingsKey<V: SettingsValue> = (id: String, default: V)

extension SettingsKeyPath {
    /// Creates a settings key as a tuple of an ID and a default value.
    fileprivate var key: SettingsKey<Value> {
        let key = String(describing: self)
        let defaultValue = Root()[keyPath: self]
        return (key, default: defaultValue)
    }
}

// Supported `UserDefaults` types
extension String: SettingsValue {}
extension Bool: SettingsValue {}
extension Int: SettingsValue {}
extension Double: SettingsValue {}
extension PersistentIdentifier: SettingsValue {}
extension Optional: SettingsValue where Wrapped: SettingsValue {}

// Wrapper around `AppStorage` initialization
private func createAppStore<Value>(
    key: SettingsKey<Value>, store: UserDefaults? = nil
) -> AppStorage<Value>? {
    switch key {
    // String =================================================================
    case let key as SettingsKey<String>:
        return AppStorage(wrappedValue: key.default, key.id, store: store) as? AppStorage
    case let key as SettingsKey<String?>:
        return AppStorage<String?>(key.id, store: store) as? AppStorage
    // Bool ===================================================================
    case let key as SettingsKey<Bool>:
        return AppStorage(wrappedValue: key.default, key.id, store: store) as? AppStorage
    case let key as SettingsKey<Bool?>:
        return AppStorage<Bool?>(key.id, store: store) as? AppStorage
    // Int ====================================================================
    case let key as SettingsKey<Int>:
        return AppStorage(wrappedValue: key.default, key.id, store: store) as? AppStorage
    case let key as SettingsKey<Int?>:
        return AppStorage<Int?>(key.id, store: store) as? AppStorage
    // Double =================================================================
    case let key as SettingsKey<Double>:
        return AppStorage(wrappedValue: key.default, key.id, store: store) as? AppStorage
    case let key as SettingsKey<Double?>:
        return AppStorage<Double?>(key.id, store: store) as? AppStorage
    // PersistentIdentifier ===================================================
    case let key as SettingsKey<PersistentIdentifier>:
        return AppStorage(wrappedValue: key.default, key.id, store: store) as? AppStorage
    case let key as SettingsKey<PersistentIdentifier?>:
        return AppStorage<PersistentIdentifier?>(key.id, store: store) as? AppStorage
    // Default ================================================================
    default:
        return nil
    }
}
