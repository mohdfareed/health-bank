import Foundation
import HealthKit

struct WeightQuery: HealthQuery {
    @MainActor
    func fetch(from: Date, to: Date, store: HealthKitService) async -> [Weight] {
        let samples = await store.fetchQuantitySamples(
            for: HKQuantityType(.bodyMass),
            from: from, to: to
        )

        return samples.map { sample in
            let weightInKg = sample.quantity.doubleValue(
                for: .gramUnit(with: .kilo)
            )
            let weight = UnitDefinition.weight.convert(
                weightInKg, from: .kilograms
            )
            return Weight(  // TODO: set source properly (requires syncing)
                weight, date: sample.startDate, source: .healthKit
            )
        }
    }

    func predicate(from: Date, to: Date) -> Predicate<Weight> {
        return #Predicate {
            from <= $0.date && $0.date <= to
        }
    }
}
