import SwiftData
import SwiftUI

extension Settings {
    init(_ id: String, default: Value? = nil)
    where Value: SettingsRawValue {
        self.id = id
        self.defaultValue = `default`
    }
}

// MARK: `UserDefaults` Integration
// ============================================================================

extension UserDefaults {
    /// Get an app settings value or its default value.
    func get<T: SettingsRawValue>(_ key: Settings<T>) -> T? {
        self.object(forKey: key.id) as? T ?? key.defaultValue
    }

    /// Set an app settings to a value.
    func set<T: SettingsRawValue>(_ key: Settings<T>, to value: T?) {
        self.set(value, forKey: key.id)
    }

    /// Reset an app settings to its default value.
    func reset<T: SettingsRawValue>(_ key: Settings<T>) {
        self.set(key.defaultValue, forKey: key.id)
    }
}

// MARK: `SwiftUI` Integration
// ============================================================================

/// A property wrapper to read and write settings values. It uses the
/// `AppStorage` to store the value in the `UserDefaults` database.
/// The settings can be unset by setting the value to `nil`. The default value
/// is used when the settings value is not set.
@MainActor @propertyWrapper
struct SettingsQuery<Value: SettingsRawValue>: DynamicProperty {
    @AppStorage var storage: Value?
    private let defaultValue: Value?

    var wrappedValue: Value? {
        get { self.storage ?? self.defaultValue }
        nonmutating set { self.storage = newValue }
    }
    var projectedValue: Binding<Value?> {
        Binding(get: { self.wrappedValue }, set: { self.wrappedValue = $0 })
    }
}
extension Query { typealias Settings = SettingsQuery }

// MARK: `AppStorage` Integration
// ============================================================================

// Supported settings value types.
extension String: SettingsRawValue {}
extension Bool: SettingsRawValue {}
extension Int: SettingsRawValue {}
extension Double: SettingsRawValue {}
extension URL: SettingsRawValue {}
extension Date: SettingsRawValue {}
extension Data: SettingsRawValue {}
extension PersistentIdentifier: SettingsRawValue {}

extension SettingsQuery {
    // String =================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == String {
        self.init(
            storage: AppStorage<String?>(key.id, store: store),
            defaultValue: key.defaultValue
        )
    }
    // Bool ===================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Bool {
        self.init(
            storage: AppStorage<Bool?>(key.id, store: store),
            defaultValue: key.defaultValue
        )
    }
    // Int ====================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Int {
        self.init(
            storage: AppStorage<Int?>(key.id, store: store),
            defaultValue: key.defaultValue
        )
    }
    // Double =================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Double {
        self.init(
            storage: AppStorage<Double?>(key.id, store: store),
            defaultValue: key.defaultValue
        )
    }
    // URL ====================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == URL {
        self.init(
            storage: AppStorage<URL?>(key.id, store: store),
            defaultValue: key.defaultValue
        )
    }
    // Date ===================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Date {
        self.init(
            storage: AppStorage<Date?>(key.id, store: store),
            defaultValue: key.defaultValue
        )
    }
    // Data ===================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Data {
        self.init(
            storage: AppStorage<Data?>(key.id, store: store),
            defaultValue: key.defaultValue
        )
    }
    // PersistentIdentifier ===================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == PersistentIdentifier {
        self.init(
            storage: AppStorage<PersistentIdentifier?>(key.id, store: store),
            defaultValue: key.defaultValue
        )
    }
}
