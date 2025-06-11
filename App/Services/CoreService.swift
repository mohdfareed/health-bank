import OSLog
import SwiftUI

// MARK: Logging
// ============================================================================

/// The app's logger factory.
struct AppLogger {
    static func new<T>(for category: T.Type) -> Logger {
        return Logger(subsystem: AppID, category: "\(T.self)")
    }

    static func new<T>(for category: T) -> Logger {
        return Logger(subsystem: AppID, category: "\(T.self)")
    }
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

extension Weekday: @retroactive CaseIterable {
    /// The days of the week.
    public static var allCases: [Self] {
        [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }
}

// MARK: Helpers
// ============================================================================

extension UUID {
    /// A UUID that represents a zero value.
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
