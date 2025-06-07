import Foundation
import HealthKit
import SwiftData

// MARK: Dietary Calories
// ============================================================================

struct DietaryQuery: HealthQuery {
    @MainActor func fetch(
        from: Date, to: Date, limit: Int? = nil,
        store: HealthKitService
    ) async -> [DietaryCalorie] {
        let correlations = await store.fetchCorrelationSamples(
            for: HKCorrelationType.correlationType(forIdentifier: .food)!,
            from: from, to: to
        )

        let foods = correlations.compactMap { correlation in
            let calories = correlation.objects(
                for: HKQuantityType(.dietaryEnergyConsumed)
            ).compactMap { $0 as? HKQuantitySample }
            let protein = correlation.objects(
                for: HKQuantityType(.dietaryProtein)
            ).compactMap { $0 as? HKQuantitySample }
            let fat = correlation.objects(
                for: HKQuantityType(.dietaryFatTotal)
            ).compactMap { $0 as? HKQuantitySample }
            let carbs = correlation.objects(
                for: HKQuantityType(.dietaryCarbohydrates)
            ).compactMap { $0 as? HKQuantitySample }

            let totalCalories = calories.sum(as: .kilocalorie())
            let totalProtein = protein.sum(as: .gram())
            let totalFat = fat.sum(as: .gram())
            let totalCarbs = carbs.sum(as: .gram())

            let calorie = DietaryCalorie(
                totalCalories ?? 0,
                date: correlation.startDate,
                macros: .init(p: totalProtein, f: totalFat, c: totalCarbs),
                isInternal: correlation.sourceRevision.source.isInternal,
                id: correlation.uuid,
            )

            if totalCalories == nil {
                calorie.calories = calorie.calculatedCalories() ?? 0
            }
            if totalProtein == nil && totalFat == nil && totalCarbs == nil {
                calorie.macros = nil  // No macros available
            }
            return calorie
        }

        let samples = await store.fetchDietarySamples(
            for: HKQuantityType(.dietaryEnergyConsumed),
            from: from, to: to, limit: limit
        )

        let calories: [DietaryCalorie] = samples.compactMap { sample in
            let caloriesInKcal = sample.quantity.doubleValue(
                for: .kilocalorie()
            )
            let calories = UnitDefinition.calorie.asBase(
                caloriesInKcal, from: .kilocalories
            )
            return DietaryCalorie(
                calories, date: sample.startDate,
                isInternal: sample.sourceRevision.source.isInternal,
                id: sample.uuid,
            )
        }

        return (calories + foods).sorted { $0.date > $1.date }
    }
}
