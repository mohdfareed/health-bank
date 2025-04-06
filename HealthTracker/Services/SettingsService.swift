import SwiftData
import SwiftUI

extension Query { typealias Settings = AppStorage }  // convenience

// Supported settings value types.
extension String: SettingsValue {}
extension Bool: SettingsValue {}
extension Int: SettingsValue {}
extension Double: SettingsValue {}
extension URL: SettingsValue {}
extension Date: SettingsValue {}
extension Data: SettingsValue {}
extension PersistentIdentifier: SettingsValue {}
extension Optional: SettingsValue {}
extension UUID: SettingsValue {}

extension AppStorage {
    // String =================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == String {
        self.init(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == String? { self.init(key.id, store: store) }
    // Bool ===================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Bool {
        self.init(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Bool? { self.init(key.id, store: store) }
    // Int ====================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Int {
        self.init(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Int? { self.init(key.id, store: store) }
    // Double =================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Double {
        self.init(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Double? { self.init(key.id, store: store) }
    // URL ====================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == URL {
        self.init(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == URL? { self.init(key.id, store: store) }
    // Date ===================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Date {
        self.init(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Date? { self.init(key.id, store: store) }
    // Data ===================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Data {
        self.init(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Data? { self.init(key.id, store: store) }
    // PersistentIdentifier ===================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == PersistentIdentifier {
        self.init(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == PersistentIdentifier? { self.init(key.id, store: store) }
    // RawRepresentable | String ==============================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value: RawRepresentable, Value.RawValue == String {
        self.init(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init<R>(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == R?, R: RawRepresentable, R.RawValue == String {
        self.init(key.id, store: store)
    }
    // RawRepresentable | Int =================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value: RawRepresentable, Value.RawValue == Int {
        self.init(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init<R>(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == R?, R: RawRepresentable, R.RawValue == Int {
        self.init(key.id, store: store)
    }
}
