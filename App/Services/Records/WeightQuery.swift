import Foundation
import HealthKit

struct WeightQuery: HealthQuery {
    @MainActor
    func fetch(
        from: Date, to: Date, limit: Int? = nil,
        store: HealthKitService
    ) async -> [Weight] {
        let samples = await store.fetchQuantitySamples(
            for: HKQuantityType(.bodyMass),
            from: from, to: to, limit: limit
        )

        return samples.map { sample in
            let weightInKg = sample.quantity.doubleValue(
                for: .gramUnit(with: .kilo)
            )
            let weight = UnitDefinition.weight.asBase(
                weightInKg, from: .kilograms
            )
            return Weight(
                weight, date: sample.startDate,
                source: sample.source.dataSource
            )
        }
    }

    func predicate(
        from: Date, to: Date, limit: Int? = nil
    ) -> Predicate<Weight> {
        return #Predicate {
            from <= $0.date && $0.date <= to
        }
    }
}
