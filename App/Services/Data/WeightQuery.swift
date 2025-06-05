import Foundation
import HealthKit
import SwiftData

struct WeightQuery: HealthQuery {
    @MainActor func fetch(
        from: Date, to: Date, limit: Int? = nil,
        store: HealthKitService
    ) async -> [Weight] {
        let samples = await store.fetchQuantitySamples(
            for: HKQuantityType(.bodyMass),
            from: from, to: to, limit: limit
        )

        let weights = samples.map { sample in
            let weightInKg = sample.quantity.doubleValue(
                for: .gramUnit(with: .kilo)
            )
            let weight = UnitDefinition.weight.asBase(
                weightInKg, from: .kilograms
            )
            return Weight(
                weight, date: sample.startDate,
                source: sample.sourceRevision.source.dataSource
            )
        }

        return weights
    }

    func descriptor(from: Date, to: Date) -> FetchDescriptor<Weight> {
        let predicate = #Predicate<Weight> {
            from <= $0.date && $0.date <= to
        }
        return FetchDescriptor(
            predicate: predicate,
            sortBy: [.init(\.date, order: .reverse)]
        )
    }
}
