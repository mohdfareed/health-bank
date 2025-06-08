import Foundation
import HealthKit

/// SwiftData model for weight data.
@Observable public final class Weight: HealthData, CopyableHealthData {
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

    /// Creates a copy of this weight record for editing
    public func copy() -> Weight {
        return Weight(
            weight,
            id: id,
            source: source,
            date: date
        )
    }

    /// Copies values from another weight record to this one
    public func copyValues(from other: Weight) {
        self.weight = other.weight
        self.date = other.date
    }
}
