import SwiftData
import SwiftUI

/// A protocol to define the raw value stored in the `UserDefaults` database.
/// It mirrors the `AppStorage` interface and **must not be implemented**.
internal protocol SettingsRawValue: Sendable {}

// AppStorage supported types
extension String: SettingsRawValue {}
extension Bool: SettingsRawValue {}
extension Int: SettingsRawValue {}
extension Double: SettingsRawValue {}
extension URL: SettingsRawValue {}
extension Date: SettingsRawValue {}
extension Data: SettingsRawValue {}
extension PersistentIdentifier: SettingsRawValue {}

/// A key for a settings value in the `UserDefaults` store.
struct Settings<Value: SettingsRawValue> {
    /// The unique key for the setting in `UserDefaults`.
    let id: String
    /// The default value for the setting.
    let `default`: Value?

    init(_ id: String, _ defaultValue: Value? = nil) {
        self.id = id
        self.default = defaultValue
    }
}

// MARK: SwiftUI Integration

/// A property wrapper to read and write settings values. The property wrapper
/// uses `AppStorage` to store the value in the `UserDefaults` database.
/// The settings can be unset by setting the value to `nil`. The default value
/// is used when the settings value is not set or is not of the expected type.
@MainActor @propertyWrapper
struct SettingsQuery<Value: SettingsRawValue>: DynamicProperty {
    @AppStorage var storage: Value?
    private let `default`: Value?

    var wrappedValue: Value? {
        get { self.storage ?? self.default }
        nonmutating set {
            withAnimation(.default) { self.storage = newValue }
        }
    }

    var projectedValue: Binding<Value?> {
        Binding(get: { self.wrappedValue }, set: { self.wrappedValue = $0 })
    }
}
extension Query { typealias Settings = SettingsQuery }

// MARK: Extensions

extension UserDefaults {
    /// Set an app settings to a value or its default value.
    func set<T: SettingsRawValue>(_ key: Settings<T>, to value: T?) {
        self.set(value ?? key.default, forKey: key.id)
    }

    /// Get an app settings value or its default value.
    func get<T: SettingsRawValue>(_ key: Settings<T>) -> T? {
        self.object(forKey: key.id) as? T ?? key.default
    }

    /// Reset all settings to their default values.
    func resetSettings(domain: String = appDomain) {
        self.removePersistentDomain(forName: domain)
        self.synchronize()
    }
}

extension View {
    func resetSettings() -> some View {
        UserDefaults.standard.resetSettings()
        return self
    }
}

// MARK: `AppStorage` Integration

extension SettingsQuery where Value: SettingsRawValue {
    // String =================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == String {
        self.init(
            storage: AppStorage<String?>(key.id, store: store),
            default: key.default
        )
    }
    // Bool ===================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Bool {
        self.init(
            storage: AppStorage<Bool?>(key.id, store: store),
            default: key.default
        )
    }
    // Int ====================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Int {
        self.init(
            storage: AppStorage<Int?>(key.id, store: store),
            default: key.default
        )
    }
    // Double =================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Double {
        self.init(
            storage: AppStorage<Double?>(key.id, store: store),
            default: key.default
        )
    }
    // URL ====================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == URL {
        self.init(
            storage: AppStorage<URL?>(key.id, store: store),
            default: key.default
        )
    }
    // Date ===================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Date {
        self.init(
            storage: AppStorage<Date?>(key.id, store: store),
            default: key.default
        )
    }
    // Data ===================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Data {
        self.init(
            storage: AppStorage<Data?>(key.id, store: store),
            default: key.default
        )
    }
    // PersistentIdentifier ===================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == PersistentIdentifier {
        self.init(
            storage: AppStorage<PersistentIdentifier?>(key.id, store: store),
            default: key.default
        )
    }
}
