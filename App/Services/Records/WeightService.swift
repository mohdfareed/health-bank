import Foundation
import SwiftData

// MARK: Weight Query
// ============================================================================

struct WeightQuery: DataQuery {
    typealias Record = Weight

    private let source: DataSource
    private let dateRange: ClosedRange<Date>
    private let weightRange: ClosedRange<Double>

    init(
        from start: Date? = nil, to end: Date? = nil,
        source: DataSource? = nil,
        weightRange: ClosedRange<Double>? = nil
    ) {
        self.source = source ?? .local
        self.dateRange = .init(from: start, to: end)
        self.weightRange = weightRange ?? .init(from: nil, to: nil)
    }

    func predicate() -> Predicate<Weight> {
        #Predicate {
            $0.date >= dateRange.lowerBound
                && $0.date <= dateRange.upperBound
                && $0.source == source
                && $0.weight >= weightRange.lowerBound
                && $0.weight <= weightRange.upperBound
        }
    }

    func remote(store: HealthKitService) -> [Weight] {
        return []
    }
}

extension Weight {
    typealias Query = WeightQuery
}
