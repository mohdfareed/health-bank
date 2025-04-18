import OSLog
import SwiftData
import SwiftUI

// MARK: Logging
// ============================================================================

/// The app's logger factory.
struct AppLogger {
    static func new(for category: String) -> Logger {
        return Logger(subsystem: appID, category: category)
    }
    static func new<T>(for category: T.Type) -> Logger {
        return Logger(subsystem: appID, category: "\(T.self)")
    }
}

// MARK: Locale
// ============================================================================

/// A property wrapper to access the app's locale, applying any user settings.
@MainActor @propertyWrapper
struct AppLocale: DynamicProperty {
    @Environment(\.locale)
    private var appLocale: Locale
    private var components: Locale.Components { .init(locale: self.appLocale) }
    private let animation: Animation? = nil  // REVIEW: Animate.

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

// MARK: Extensions
// ============================================================================

extension AppTheme {
    /// The theme's color scheme.
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

extension UUID {
    /// A UUID that represents a zero value.
    public static let zero: UUID = .init(
        uuidString: "00000000-0000-0000-0000-000000000000"
    )!  // fail quickly
}

// MARK: Serialization
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
