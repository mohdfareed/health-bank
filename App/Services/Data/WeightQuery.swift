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
                isInternal: sample.sourceRevision.source.isInternal,
                id: sample.uuid
            )
        }

        return weights
    }
}
