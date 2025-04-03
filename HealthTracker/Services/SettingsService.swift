import SwiftData
import SwiftUI

/// A key for a settings value in the `UserDefaults` store.
struct SettingsKey<Value: RawRepresentable & Sendable>: Sendable
where Value.RawValue: SettingsValue {
    /// The key for the setting in `UserDefaults`.
    let id: String
    /// The default value for the setting.
    let `default`: Value

    init(_ key: String, default: Value) {
        self.id = key
        self.default = `default`
    }

    init(_ key: String) where Value: ExpressibleByNilLiteral {
        self.init(key, default: nil)
    }
}

extension View {
    func resetSettings() -> some View {
        let defaults = UserDefaults.standard
        defaults.removePersistentDomain(forName: AppLogger.appDomain)
        return self
    }
}

// MARK: SwiftUI Integration

/// A property wrapper to read and write settings values. The property wrapper
/// uses `AppStorage` to store the value in the `UserDefaults` database.
/// The wrapper uses `RawRepresentable` to convert settings values to and from
/// the underlying type stored in `UserDefaults`. The settings can be unset
/// by setting the value to `nil`. The default value is used when the settings
/// value is not set or is not of the expected type.
@MainActor @propertyWrapper
struct SettingsQuery<Value: RawRepresentable & Sendable>: DynamicProperty
where Value.RawValue: SettingsValue {
    private let `default`: Value
    @AppStorage var storage: Value.RawValue

    var wrappedValue: Value {
        get { Value(rawValue: self.storage) ?? self.default }
        nonmutating set { self.storage = newValue.rawValue }
    }

    var projectedValue: Binding<Value> {
        Binding(get: { self.wrappedValue }, set: { self.wrappedValue = $0 })
    }

    init(_ key: SettingsKey<Value>, store: UserDefaults? = nil) {
        self.default = key.default
        self._storage = createStorage(
            default: key.default.rawValue, id: key.id, store: store
        )
    }
}
extension Query { typealias Settings = SettingsQuery }

// MARK: Supported Types

/// A protocol to define the raw value stored in the `UserDefaults` database.
/// It mirrors the `AppStorage` interface and **must not be implemented**.
internal protocol SettingsValue: RawRepresentable {}
extension Optional: SettingsValue, @retroactive RawRepresentable {
    public init?(rawValue: Self) { self = rawValue }
    public var rawValue: Self { self }
}

// AppStorage supported types
extension String: SettingsValue, @retroactive RawRepresentable {}
extension Bool: SettingsValue, @retroactive RawRepresentable {}
extension Int: SettingsValue, @retroactive RawRepresentable {}
extension Double: SettingsValue, @retroactive RawRepresentable {}
extension URL: SettingsValue, @retroactive RawRepresentable {}
extension Date: SettingsValue, @retroactive RawRepresentable {}
extension Data: SettingsValue, @retroactive RawRepresentable {}
extension PersistentIdentifier: SettingsValue, @retroactive RawRepresentable {}

// MARK: `AppStorage` Integration

private func createStorage<Value: SettingsValue>(
    default: Value, id: String, store: UserDefaults? = nil
) -> AppStorage<Value> {
    switch AppStorage<Value>.self {
    // String =================================================================
    case is AppStorage<String>.Type:
        let value = `default` as! String
        return AppStorage(wrappedValue: value, id, store: store) as! AppStorage
    case is AppStorage<String?>.Type:
        return AppStorage<String?>(id, store: store) as! AppStorage

    // Bool ===================================================================
    case is AppStorage<Bool>.Type:
        let value = `default` as! Bool
        return AppStorage(wrappedValue: value, id, store: store) as! AppStorage
    case is AppStorage<Bool?>.Type:
        return AppStorage<Bool?>(id, store: store) as! AppStorage

    // Int ====================================================================
    case is AppStorage<Int>.Type:
        let value = `default` as! Int
        return AppStorage(wrappedValue: value, id, store: store) as! AppStorage
    case is AppStorage<Int?>.Type:
        return AppStorage<Int?>(id, store: store) as! AppStorage

    // Double =================================================================
    case is AppStorage<Double>.Type:
        let value = `default` as! Double
        return AppStorage(wrappedValue: value, id, store: store) as! AppStorage
    case is AppStorage<Double?>.Type:
        return AppStorage<Double?>(id, store: store) as! AppStorage

    // URL ====================================================================
    case is AppStorage<URL>.Type:
        let value = `default` as! URL
        return AppStorage(wrappedValue: value, id, store: store) as! AppStorage
    case is AppStorage<URL?>.Type:
        return AppStorage<URL?>(id, store: store) as! AppStorage

    // Date ===================================================================
    case is AppStorage<Date>.Type:
        let value = `default` as! Date
        return AppStorage(wrappedValue: value, id, store: store) as! AppStorage
    case is AppStorage<Date?>.Type:
        return AppStorage<Date?>(id, store: store) as! AppStorage

    // Data ===================================================================
    case is AppStorage<Data>.Type:
        let value = `default` as! Data
        return AppStorage(wrappedValue: value, id, store: store) as! AppStorage
    case is AppStorage<Data?>.Type:
        return AppStorage<Data?>(id, store: store) as! AppStorage

    // PersistentIdentifier ===================================================
    case is AppStorage<PersistentIdentifier>.Type:
        let value = `default` as! PersistentIdentifier
        return AppStorage(wrappedValue: value, id, store: store) as! AppStorage
    case is AppStorage<PersistentIdentifier?>.Type:
        let storage = AppStorage<PersistentIdentifier?>(id, store: store)
        return storage as! AppStorage

    // Unsupported ============================================================
    default:
        fatalError(
            "Unsupported settings type: \(id) = \(type(of: `default`))"
        )
    }
}
