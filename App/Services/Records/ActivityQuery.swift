import Foundation
import HealthKit

struct ActivityQuery: HealthQuery {
    @MainActor
    func fetch(from: Date, to: Date, store: HealthKitService) async -> [ActiveEnergy] {
        let samples = await store.fetchQuantitySamples(
            for: HKQuantityType(.activeEnergyBurned),
            from: from, to: to
        )

        return samples.map { sample in
            let caloriesInKcal = sample.quantity.doubleValue(
                for: .kilocalorie()
            )
            let calories = UnitDefinition.calorie.convert(
                caloriesInKcal, from: .kilocalories
            )
            return ActiveEnergy(  // TODO: set source properly (requires syncing)
                calories,
                date: sample.startDate,
                source: .healthKit
            )
        }
    }

    func predicate(from: Date, to: Date) -> Predicate<ActiveEnergy> {
        return #Predicate<ActiveEnergy> {
            from <= $0.date && $0.date <= to
        }
    }
}
