import SwiftData
import SwiftUI

// MARK: Primitive Types
// ============================================================================

extension Query { typealias Settings = AppStorage }  // convenience

// Types natively supported by `UserDefaults`.
extension String: SettingsValue {}
extension Bool: SettingsValue {}
extension Int: SettingsValue {}
extension Double: SettingsValue {}
extension URL: SettingsValue {}
extension Date: SettingsValue {}
extension Data: SettingsValue {}
extension PersistentIdentifier: SettingsValue {}
extension Optional: SettingsValue {}

// MARK: Supported Types
// ============================================================================

// App locale.
extension Weekday: SettingsValue {}
extension MeasurementSystem: SettingsValue, @retroactive RawRepresentable {
    public var rawValue: String { self.identifier }
    public init?(rawValue: String) { self.init(rawValue) }
}

// Model IDs.
extension UUID: SettingsValue, @retroactive RawRepresentable {
    public var rawValue: String { self.uuidString }
    public init?(rawValue: String) { self.init(uuidString: rawValue) }
}

// MARK: Reset Settings
// ============================================================================

extension UserDefaults {
    /// Resets the app's resettable settings to their default values.
    func resetSettings() {
        for settings in [
            AnySettings(.theme),
            .init(.notifications),
            .init(.unitSystem),
            .init(.firstDayOfWeek),
        ] {
            self.removeObject(forKey: settings.id)
        }
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
    func set(_ value: String?, for key: Settings<String>) {
        self.set(value, forKey: key.id)
    }
    // Bool ===================================================================
    func bool(for key: Settings<Bool>) -> Bool {
        self.bool(forKey: key.id)
    }
    func bool(for key: Settings<Bool?>) -> Bool? {
        self.object(forKey: key.id) as? Bool
    }
    func set(_ value: Bool?, for key: Settings<Bool>) {
        self.set(value, forKey: key.id)
    }
    // Int ====================================================================
    func int(for key: Settings<Int>) -> Int {
        self.integer(forKey: key.id)
    }
    func int(for key: Settings<Int?>) -> Int? {
        self.object(forKey: key.id) as? Int
    }
    func set(_ value: Int?, for key: Settings<Int>) {
        self.set(value, forKey: key.id)
    }
    // Double =================================================================
    func double(for key: Settings<Double>) -> Double {
        self.double(forKey: key.id)
    }
    func double(for key: Settings<Double?>) -> Double? {
        self.object(forKey: key.id) as? Double
    }
    func set(_ value: Double?, for key: Settings<Double>) {
        self.set(value, forKey: key.id)
    }
    // URL ====================================================================
    func url(for key: Settings<URL>) -> URL {
        self.url(forKey: key.id) ?? key.default
    }
    func url(for key: Settings<URL?>) -> URL? {
        self.url(forKey: key.id)
    }
    func set(_ value: URL?, for key: Settings<URL>) {
        self.set(value, forKey: key.id)
    }
    // Date ===================================================================
    func date(for key: Settings<Date>) -> Date {
        self.object(forKey: key.id) as? Date ?? key.default
    }
    func date(for key: Settings<Date?>) -> Date? {
        self.object(forKey: key.id) as? Date
    }
    func set(_ value: Date?, for key: Settings<Date>) {
        self.set(value, forKey: key.id)
    }
    // Data ===================================================================
    func data(for key: Settings<Data>) -> Data {
        self.data(forKey: key.id) ?? key.default
    }
    func data(for key: Settings<Data?>) -> Data? {
        self.data(forKey: key.id)
    }
    func set(_ value: Data?, for key: Settings<Data>) {
        self.set(value, forKey: key.id)
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
    func set<R>(_ value: R?, for key: Settings<R>)
    where R: RawRepresentable, R.RawValue == String {
        self.set(value?.rawValue, forKey: key.id)
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
    func set<R>(_ value: R?, for key: Settings<R>)
    where R: RawRepresentable, R.RawValue == Int {
        self.set(value?.rawValue, forKey: key.id)
    }
}
