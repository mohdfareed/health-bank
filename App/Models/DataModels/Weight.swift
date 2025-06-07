import Foundation
import HealthKit

/// SwiftData model for weight data.
@Observable public final class Weight: HealthData {
    public let id: UUID
    public let source: DataSource
    public var date: Date

    /// The weight value.
    public var weight: Double

    public init(
        _ weight: Double,
        id: UUID = UUID(),
        source: DataSource = .app,
        date: Date = Date(),
    ) {
        self.weight = weight

        self.id = id
        self.source = source
        self.date = date
    }
}
