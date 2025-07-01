import Foundation
import HealthKit
import SwiftData

public struct WeightQuery: HealthQuery {
    public func save(_ data: Weight, store: HealthKitService) async throws {
        try await delete(data, store: store)

        let weightInKg = Measurement(
            value: data.weight, unit: UnitDefinition.weight.baseUnit
        ).converted(to: UnitMass.kilograms).value

        let quantity = HKQuantity(
            unit: HealthKitDataType.bodyMass.baseUnit,
            doubleValue: weightInKg
        )

        let sample = HKQuantitySample(
            type: HKQuantityType(.bodyMass), quantity: quantity,
            start: data.date, end: data.date
        )

        try await store.save(sample, of: sample.sampleType)
    }

    public func delete(_ data: Weight, store: HealthKitService) async throws {
        try await store.delete(
            data.id, of: HealthKitDataType.bodyMass.sampleType
        )
    }

    @MainActor public func fetch(
        from: Date, to: Date, limit: Int? = nil,
        store: HealthKitService
    ) async -> [Weight] {
        let samples = await store.fetchQuantitySamples(
            for: .bodyMass, from: from, to: to, limit: limit
        )

        let weights = samples.map { sample in
            let weightInKg = sample.quantity.doubleValue(
                for: HealthKitDataType.bodyMass.baseUnit
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
