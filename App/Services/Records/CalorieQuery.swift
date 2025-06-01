import Foundation
import HealthKit

// MARK: Dietary Calories
// ============================================================================

struct DietaryQuery: HealthQuery {
    @MainActor
    func fetch(from: Date, to: Date, store: HealthKitService) async -> [DietaryCalorie] {
        let correlations = await store.fetchCorrelationSamples(
            for: HKCorrelationType.correlationType(forIdentifier: .food)!,
            from: from, to: to
        )

        return correlations.compactMap { correlation in
            let calories = correlation.objects(
                for: HKQuantityType(.dietaryEnergyConsumed)
            )
            let protein = correlation.objects(
                for: HKQuantityType(.dietaryProtein)
            )
            let fat = correlation.objects(
                for: HKQuantityType(.dietaryFatTotal)
            )
            let carbs = correlation.objects(
                for: HKQuantityType(.dietaryCarbohydrates)
            )

            let totalCalories = calories.sum(as: .kilocalorie())
            let totalProtein = protein.sum(as: .gram())
            let totalFat = fat.sum(as: .gram())
            let totalCarbs = carbs.sum(as: .gram())

            let calorie = DietaryCalorie(
                totalCalories ?? 0,
                date: correlation.startDate, source: .healthKit,
                macros: .init(p: totalProtein, f: totalFat, c: totalCarbs)
            )

            if totalCalories == nil {
                calorie.calories = calorie.calculatedCalories() ?? 0
            }
            if totalProtein == nil && totalFat == nil && totalCarbs == nil {
                calorie.macros = nil  // No macros available
            }
            return calorie
        }
    }

    func predicate(from: Date, to: Date) -> Predicate<DietaryCalorie> {
        return #Predicate {
            from <= $0.date && $0.date <= to
        }
    }
}

// MARK: Resting Calories
// ============================================================================

struct RestingQuery: HealthQuery {
    @MainActor
    func fetch(
        from: Date, to: Date, store: HealthKitService
    ) async -> [RestingEnergy] {
        let samples = await store.fetchQuantitySamples(
            for: HKQuantityType(.basalEnergyBurned),
            from: from, to: to
        )

        return samples.map { sample in
            let caloriesInKcal = sample.quantity.doubleValue(
                for: .kilocalorie()
            )
            let calories = UnitDefinition.calorie.asBase(
                caloriesInKcal, from: .kilocalories
            )
            return RestingEnergy(  // TODO: Set source properly (requires syncing)
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
