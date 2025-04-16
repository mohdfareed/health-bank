import Foundation
import OSLog
import SwiftData
import SwiftUI

// MARK: Core Services
// ============================================================================

/// An application error.
enum AppError: Error {
    case runtimeError(String, Error? = nil)
}

/// The app's logger factory.
struct AppLogger {
    static func new(for category: String) -> Logger {
        return Logger(subsystem: appDomain, category: category)
    }
    static func new<T>(for category: T.Type) -> Logger {
        return Logger(subsystem: appDomain, category: "\(T.self)")
    }
}

extension UUID {
    /// A UUID that represents a zero value.
    public static let zero: UUID = .init(
        uuidString: "00000000-0000-0000-0000-000000000000"
    )!  // fail early
}

@MainActor extension Binding {
    /// A binding that defaults to a value if the wrapped value is nil.
    func defaulted<T>(to defaultValue: T) -> Binding<T> where Value == T? {
        return Binding<T>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}

// MARK: App Locale
// ============================================================================

/// A property wrapper to access the app's locale, applying any user settings.
@MainActor @propertyWrapper struct AppLocale: DynamicProperty {
    // TODO: Test environment react updates.
    @Environment(\.locale) var appLocale: Locale
    var components: Locale.Components { .init(locale: self.appLocale) }
    // TODO: Animate.
    let animation: Animation? = nil

    @AppStorage(AppSettings.unitSystem)
    var unitSystem: Locale.MeasurementSystem?
    @AppStorage(AppSettings.firstDayOfWeek)
    var firstDayOfWeek: Locale.Weekday?

    var wrappedValue: Locale {
        var components = self.components
        components.firstDayOfWeek =
            self.firstDayOfWeek
            ?? components.firstDayOfWeek
        components.measurementSystem =
            self.unitSystem
            ?? components.measurementSystem
        return Locale(components: components)
    }
    var projectedValue: Self { self }
}

// MARK: JSON Serialization
// ============================================================================

// Serialization
extension Encodable {
    var json: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data: Data

        do {
            data = try encoder.encode(self)
            guard let json = String(data: data, encoding: .utf8) else {
                throw AppError.runtimeError(
                    "Failed to create string from JSON data: \(data)"
                )
            }
            return json
        } catch {
            AppLogger.new(for: Self.self).error(
                "Failed to encode JSON: \(error)"
            )
            return nil
        }
    }
}

// Deserialization
extension Decodable {
    init?(json: String) {
        do {
            guard !json.isEmpty else { return nil }
            guard let data = json.data(using: .utf8) else {
                throw AppError.runtimeError(
                    "Failed to generate data from JSON string: \(json)"
                )
            }
            self = try JSONDecoder().decode(Self.self, from: data)
        } catch {
            AppLogger.new(for: Self.self).error(
                "Failed to decode JSON: \(error)"
            )
            return nil
        }
    }
}
