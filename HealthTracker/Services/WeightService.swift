import Foundation
import SwiftData

// MARK: Queries
// ============================================================================

extension RemoteQuery {
    static func weight(
        from: Date = Date().floored(to: .day), to: Date = Date(),
        min: Double = 0, max: Double = .infinity
    ) -> WeightQuery<Model> where Model: Weight {
        .init(from: from, to: to, min: min, max: max)
    }
}

// MARK: Local Queries
// ============================================================================

extension WeightQuery: CoreQuery where C: PersistentModel {
    var descriptor: FetchDescriptor<C> {
        let (from, to, min, max) = (self.from, self.to, self.min, self.max)
        return FetchDescriptor<C>(
            predicate: #Predicate {
                $0.date >= from && $0.date <= to
                    && $0.weight > min && $0.weight < max
            },
            sortBy: [SortDescriptor(\.date)]
        )
    }
}
