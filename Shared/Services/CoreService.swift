import OSLog
import SwiftUI

// MARK: - Logging Infrastructure
// ============================================================================

/// Centralized logger factory using OSLog for structured logging.
public struct AppLogger {
    /// Creates logger for a specific type.
    public static func new<T>(for category: T.Type) -> Logger {
        return Logger(subsystem: AppID, category: "\(T.self)")
    }

    /// Creates logger for a specific instance.
    public static func new<T>(for category: T) -> Logger {
        return Logger(subsystem: AppID, category: "\(T.self)")
    }
}

// MARK: - Core Extensions
// ============================================================================

extension AppTheme {
    /// The theme's color scheme.
    public var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

extension Weekday: @retroactive CaseIterable {
    /// The days of the week.
    public static var allCases: [Self] {
        [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }
}

// MARK: - Helper Functions
// ============================================================================

extension UUID {
    /// Zero UUID constant for singleton patterns.
    public static let zero: UUID = .init(
        uuidString: "00000000-0000-0000-0000-000000000000"
    )!  // tested
}

extension View {
    @ViewBuilder func transform(
        @ViewBuilder _ transform: (Self) -> some View
    ) -> some View {
        transform(self)
    }
}

@MainActor extension Binding {
    /// A binding that defaults to a value if the wrapped value is nil.
    func defaulted<T>(to defaultValue: T) -> Binding<T> where Value == T? {
        .init(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }

    /// A binding that defaults to a value if the wrapped value is nil.
    func optional(_ defaultValue: Value) -> Binding<Value?> {
        .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 ?? defaultValue }
        )
    }
}

// MARK: - JSON Serialization
// ============================================================================

extension Encodable {
    /// Converts object to pretty-printed JSON string.
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

extension Decodable {
    /// Creates object from JSON string.
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
