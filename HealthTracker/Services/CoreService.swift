import Foundation
import OSLog
import SwiftData
import SwiftUI

/// A logger for the app.
struct AppLogger {
    private static let defaultSubsystem: String = {
        Bundle.main.bundleIdentifier ?? "Debug.HealthTracker"
    }()

    static func new(for category: String) -> Logger {
        return Logger(
            subsystem: AppLogger.defaultSubsystem, category: category
        )
    }

    static func new<T>(for category: T.Type) -> Logger {
        return Logger(
            subsystem: AppLogger.defaultSubsystem, category: "\(T.self)"
        )
    }
}

// MARK: Extensions

extension Decodable {
    init?(json: String) {
        guard let data = json.data(using: .utf8) else { return nil }
        self = try! JSONDecoder().decode(Self.self, from: data)
    }
}

extension Encodable {
    var json: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension RawRepresentable where Self: Codable, Self.RawValue == String {
    public var rawValue: String? { self.json }
    public init?(rawValue: String) {
        self.init(json: rawValue)
    }
}

extension UUID: @retroactive RawRepresentable {
    public var rawValue: String { self.uuidString }
    public init?(rawValue: String) {
        self.init(uuidString: rawValue)
    }
}
