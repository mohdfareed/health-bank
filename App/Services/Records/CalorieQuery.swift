import Foundation
import HealthKit

struct DietaryQuery: HealthQuery {
    @MainActor
    func fetch(from: Date, to: Date, store: HealthKitService) async -> [DietaryCalorie] {
        let samples = await store.fetchQuantitySamples(
            for: HKQuantityType(.dietaryEnergyConsumed),
            from: from, to: to
        )

        return samples.map { sample in
            let caloriesInKcal = sample.quantity.doubleValue(
                for: .kilocalorie()
            )
            let calories = UnitDefinition.calorie.convert(
                caloriesInKcal, from: .kilocalories
            )
            return DietaryCalorie(  // TODO: set source properly (requires syncing)
                calories, date: sample.startDate, source: .healthKit
            )
        }
    }

    func predicate(from: Date, to: Date) -> Predicate<DietaryCalorie> {
        return #Predicate {
            from <= $0.date && $0.date <= to
        }
    }
}

struct RestingQuery: HealthQuery {
    @MainActor
    func fetch(from: Date, to: Date, store: HealthKitService) async -> [RestingEnergy] {
        guard store.isActive else { return [] }

        let samples = await store.fetchQuantitySamples(
            for: HKQuantityType(.basalEnergyBurned),
            from: from,
            to: to
        )

        return samples.map { sample in
            let caloriesInKcal = sample.quantity.doubleValue(
                for: .kilocalorie()
            )
            let calories = UnitDefinition.calorie.convert(
                caloriesInKcal, from: .kilocalories
            )
            return RestingEnergy(  // TODO: set source properly (requires syncing)
                calories, date: sample.startDate, source: .healthKit
            )
        }
    }

    func predicate(from: Date, to: Date) -> Predicate<RestingEnergy> {
        return #Predicate {
            from <= $0.date && $0.date <= to
        }
    }
}
