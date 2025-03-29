import Foundation
import OSLog

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

extension Encodable {
    var asJSON: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension Decodable {
    static func fromJSON(_ json: String) -> Self? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Self.self, from: data)
    }
}
