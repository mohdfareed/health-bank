import Foundation
import SwiftData

/// SwiftData model for weight records.
@Model public final class Weight: HealthRecord {
    public var date: Date
    public var source: DataSource

    /// The weight value.
    public var weight: Double

    public init(
        _ value: Double, date: Date = Date(), source: DataSource = .local,
    ) {
        self.weight = value
        self.date = date
        self.source = source
    }
}
