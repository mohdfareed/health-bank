import Foundation
import OSLog
import SwiftData
import SwiftUI

// MARK: Core Services
// ============================================================================

/// An application error.
enum AppError: Error {
    case runtimeError(String)
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

// MARK: JSON Serialization
// ============================================================================

extension RawRepresentable where Self: Codable {
    public var rawValue: String? { self.json }
    public init?(rawValue: String?) {
        guard let rawValue = rawValue else { return nil }
        self.init(json: rawValue)
    }
}

extension UUID: @retroactive RawRepresentable {
    public var rawValue: String { self.uuidString }
    public init?(rawValue: String) { self.init(uuidString: rawValue) }
}

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
