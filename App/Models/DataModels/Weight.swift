import Foundation
import SwiftData

/// SwiftData model for weight data.
public final class Weight: HealthDate {
    public var id: UUID
    public var date: Date
    public var isInternal: Bool

    /// The weight value.
    public var weight: Double

    public init(
        _ value: Double, date: Date = Date(),
        isInternal: Bool = true, id: UUID = UUID()
    ) {
        self.weight = value

        self.id = id
        self.date = date
        self.isInternal = isInternal
    }
}
