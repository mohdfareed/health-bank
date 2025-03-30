import SwiftData
import SwiftUI

struct SettingsKey<Type: Sendable>: Sendable {
    let id: String
    let defaultValue: Type
    init(_ key: String, default: Type) {
        self.defaultValue = `default`
        self.id = key
    }
    init(_ key: String) where Type: ExpressibleByNilLiteral {
        self.init(key, default: nil)
    }
}

@propertyWrapper struct Settings<Type: Sendable> {
    private let key: SettingsKey<Type>
    var wrappedValue: SettingsKey<Type> { key }

    init(_ scope: Any? = nil, _ key: String, default: Type) {
        self.key = SettingsKey<Type>(
            "\(scope ?? Any.self).\(key)", default: `default`
        )
    }

    init(_ scope: Any? = nil, _ key: String)
    where Type: ExpressibleByNilLiteral {
        self.init(scope, key, default: nil)
    }
}

@MainActor @propertyWrapper
struct SettingsQuery<Value>: DynamicProperty {
    @AppStorage private var value: Value
    var wrappedValue: Value {
        get { value }
        set { value = newValue }
    }
    var projectedValue: Binding<Value> {
        Binding(
            get: { value }, set: { value = $0 }
        )
    }
}

extension Query {
    typealias Settings = SettingsQuery
}

extension SettingsQuery {
    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil) where Value == Bool {
        self._value = AppStorage(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil) where Value == Bool? {
        self._value = AppStorage(key.id, store: store)
    }

    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil) where Value == Int {
        self._value = AppStorage(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil) where Value == Int? {
        self._value = AppStorage(key.id, store: store)
    }

    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil) where Value == Double {
        self._value = AppStorage(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil) where Value == Double? {
        self._value = AppStorage(key.id, store: store)
    }

    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil) where Value == String {
        self._value = AppStorage(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil) where Value == String? {
        self._value = AppStorage(key.id, store: store)
    }

    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil) where Value == URL {
        self._value = AppStorage(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil) where Value == URL? {
        self._value = AppStorage(key.id, store: store)
    }

    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil) where Value == Date {
        self._value = AppStorage(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil) where Value == Date? {
        self._value = AppStorage(key.id, store: store)
    }

    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil) where Value == Data {
        self._value = AppStorage(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil) where Value == Data? {
        self._value = AppStorage(key.id, store: store)
    }

    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil)
    where Value == PersistentIdentifier {
        self._value = AppStorage(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil)
    where Value == PersistentIdentifier? {
        self._value = AppStorage(key.id, store: store)
    }

    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil)
    where Value: RawRepresentable, Value.RawValue == String {
        self._value = AppStorage(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init<R>(_ key: SettingsKey<Value>, store: UserDefaults? = nil)
    where Value == R?, R: RawRepresentable, R.RawValue == String {
        self._value = AppStorage(key.id, store: store)
    }
    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil)
    where Value: RawRepresentable, Value.RawValue == Int {
        self._value = AppStorage(wrappedValue: key.defaultValue, key.id, store: store)
    }
    init<R>(_ key: SettingsKey<Value>, store: UserDefaults? = nil)
    where Value == R?, R: RawRepresentable, R.RawValue == Int {
        self._value = AppStorage(key.id, store: store)
    }
}
