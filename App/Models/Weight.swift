import Foundation
import SwiftData

/// SwiftData model for weight records.
@Model public final class Weight: DataRecord {
    public var date: Date
    public var source: DataSource

    /// The weight value.
    public var weight: Double

    public init(date: Date, weight: Double, source: DataSource = .local) {
        self.date = date
        self.weight = weight
        self.source = source
    }
}
