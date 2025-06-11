import Foundation
import HealthKit
import SwiftData

struct WeightQuery: HealthQuery {
    @MainActor func fetch(
        from: Date, to: Date, limit: Int? = nil,
        store: HealthKitService
    ) async -> [Weight] {
        let samples = await store.fetchQuantitySamples(
            for: .bodyMass, from: from, to: to, limit: limit
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

    func save(_ data: Weight, store: HealthKitService) async throws {
        let weightInKg = Measurement(
            value: data.weight, unit: UnitDefinition.weight.baseUnit
        ).converted(to: UnitMass.kilograms).value
        let quantity = HKQuantity(
            unit: .gramUnit(with: .kilo), doubleValue: weightInKg
        )
        let sample = HKQuantitySample(
            type: HKQuantityType(.bodyMass), quantity: quantity,
            start: data.date, end: data.date
        )

        try await delete(data, store: store)
        try await store.save(sample, of: sample.sampleType)
    }

    func delete(_ data: Weight, store: HealthKitService) async throws {
        try await store.delete(
            data.id, of: HealthKitDataType.bodyMass.sampleType
        )
    }
}
