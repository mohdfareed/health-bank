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

// Implicitly supported types:
// `RawRepresentable<String|Int>`

// Support `UUID` in app storage.
extension UUID: SettingsValue, @retroactive RawRepresentable {
    public var rawValue: String { self.uuidString }
    public init?(rawValue: String) { self.init(uuidString: rawValue) }
}

// Support `Codable` in app storage. Requires the type to implement
// `RawRepresentable`. A default implementation is provided.
extension RawRepresentable where Self: Codable {
    public var rawValue: String? { self.json }
    public init?(rawValue: String?) {
        guard let rawValue = rawValue else { return nil }
        self.init(json: rawValue)
    }
}

// MARK: `AppStorage` Integration
// ============================================================================

extension AppStorage {
    // String =================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == String {
        self.init(wrappedValue: key.default, key.id, store: store)
    }
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == String? { self.init(key.id, store: store) }
    // Bool ===================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Bool {
        self.init(wrappedValue: key.default, key.id, store: store)
    }
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Bool? { self.init(key.id, store: store) }
    // Int ====================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Int {
        self.init(wrappedValue: key.default, key.id, store: store)
    }
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Int? { self.init(key.id, store: store) }
    // Double =================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Double {
        self.init(wrappedValue: key.default, key.id, store: store)
    }
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Double? { self.init(key.id, store: store) }
    // URL ====================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == URL {
        self.init(wrappedValue: key.default, key.id, store: store)
    }
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == URL? { self.init(key.id, store: store) }
    // Date ===================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Date {
        self.init(wrappedValue: key.default, key.id, store: store)
    }
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Date? { self.init(key.id, store: store) }
    // Data ===================================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Data {
        self.init(wrappedValue: key.default, key.id, store: store)
    }
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == Data? { self.init(key.id, store: store) }
    // PersistentIdentifier ===================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == PersistentIdentifier {
        self.init(wrappedValue: key.default, key.id, store: store)
    }
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == PersistentIdentifier? { self.init(key.id, store: store) }
    // RawRepresentable | String ==============================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value: RawRepresentable, Value.RawValue == String {
        self.init(wrappedValue: key.default, key.id, store: store)
    }
    init<R>(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == R?, R: RawRepresentable, R.RawValue == String {
        self.init(key.id, store: store)
    }
    // RawRepresentable | Int =================================================
    init(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value: RawRepresentable, Value.RawValue == Int {
        self.init(wrappedValue: key.default, key.id, store: store)
    }
    init<R>(_ key: Settings<Value>, store: UserDefaults? = nil)
    where Value == R?, R: RawRepresentable, R.RawValue == Int {
        self.init(key.id, store: store)
    }
}

// MARK: `UserDefaults` Integration
// ============================================================================

extension UserDefaults {
    // String =================================================================
    func string(for key: Settings<String>) -> String {
        self.string(forKey: key.id) ?? key.default
    }
    func string(for key: Settings<String?>) -> String? {
        self.string(forKey: key.id)
    }
    // Bool ===================================================================
    func bool(for key: Settings<Bool>) -> Bool {
        self.bool(forKey: key.id)
    }
    func bool(for key: Settings<Bool?>) -> Bool? {
        self.object(forKey: key.id) as? Bool
    }
    // Int ====================================================================
    func int(for key: Settings<Int>) -> Int {
        self.integer(forKey: key.id)
    }
    func int(for key: Settings<Int?>) -> Int? {
        self.object(forKey: key.id) as? Int
    }
    // Double =================================================================
    func double(for key: Settings<Double>) -> Double {
        self.double(forKey: key.id)
    }
    func double(for key: Settings<Double?>) -> Double? {
        self.object(forKey: key.id) as? Double
    }
    // URL ====================================================================
    func url(for key: Settings<URL>) -> URL {
        self.url(forKey: key.id) ?? key.default
    }
    func url(for key: Settings<URL?>) -> URL? {
        self.url(forKey: key.id)
    }
    // Date ===================================================================
    func date(for key: Settings<Date>) -> Date {
        self.object(forKey: key.id) as? Date ?? key.default
    }
    func date(for key: Settings<Date?>) -> Date? {
        self.object(forKey: key.id) as? Date
    }
    // Data ===================================================================
    func data(for key: Settings<Data>) -> Data {
        self.data(forKey: key.id) ?? key.default
    }
    func data(for key: Settings<Data?>) -> Data? {
        self.data(forKey: key.id)
    }
    // PersistentIdentifier - Unsupported =====================================
    // RawRepresentable | String ==============================================
    func rawRepresentable<R>(for key: Settings<R>) -> R
    where R: RawRepresentable, R.RawValue == String {
        guard let rawValue = self.string(forKey: key.id) else {
            return key.default
        }
        return R(rawValue: rawValue) ?? key.default
    }
    func rawRepresentable<R>(for key: Settings<R?>) -> R?
    where R: RawRepresentable, R.RawValue == String {
        guard let rawValue = self.string(forKey: key.id) else { return nil }
        return R(rawValue: rawValue)
    }
    // RawRepresentable | Int =================================================
    func rawRepresentable<R>(for key: Settings<R>) -> R
    where R: RawRepresentable, R.RawValue == Int {
        guard let rawValue = self.object(forKey: key.id) as? Int else {
            return key.default
        }
        return R(rawValue: rawValue) ?? key.default
    }
    func rawRepresentable<R>(for key: Settings<R?>) -> R?
    where R: RawRepresentable, R.RawValue == Int {
        guard let rawValue = self.object(forKey: key.id) as? Int else {
            return nil
        }
        return R(rawValue: rawValue)
    }
}
