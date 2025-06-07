import Foundation
import HealthKit
import SwiftData

struct WeightQuery: HealthQuery {
    func save(store: HealthKitService) async throws {

    }

    func delete(store: HealthKitService) async throws {

    }

    func update(store: HealthKitService) async throws {

    }

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
                weight,
                id: sample.uuid,
                source: sample.sourceRevision.source.dataSource,
                date: sample.startDate,
            )
        }

        return weights
    }
}
