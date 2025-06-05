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
                source: correlation.sourceRevision.source.dataSource,
                macros: .init(p: totalProtein, f: totalFat, c: totalCarbs)
            )

            if totalCalories == nil {
                calorie.calories = calorie.calculatedCalories() ?? 0
            }
            if totalProtein == nil && totalFat == nil && totalCarbs == nil {
                calorie.macros = nil  // No macros available
            }
            return calorie
        }.sorted { $0.date > $1.date }.prefix(limit ?? Int.max)

        let samples = await store.fetchQuantitySamples(
            for: HKQuantityType(.dietaryEnergyConsumed),
            from: from, to: to, limit: limit
        )

        let calories: [DietaryCalorie] = samples.compactMap { sample in
            // Check if sample already in workouts
            if correlations.contains(where: {
                $0.startDate <= sample.startDate
                    && $0.endDate >= sample.endDate
            }) {
                return nil
            }

            let caloriesInKcal = sample.quantity.doubleValue(
                for: .kilocalorie()
            )
            let calories = UnitDefinition.calorie.asBase(
                caloriesInKcal, from: .kilocalories
            )
            return DietaryCalorie(
                calories, date: sample.startDate,
                source: sample.sourceRevision.source.dataSource
            )
        }

        // Combine the calories from foods and samples
        return calories + foods
    }

    func descriptor(from: Date, to: Date) -> FetchDescriptor<DietaryCalorie> {
        let predicate = #Predicate<DietaryCalorie> {
            from <= $0.date && $0.date <= to
        }
        return FetchDescriptor(
            predicate: predicate,
            sortBy: [.init(\.date, order: .reverse)]
        )
    }
}

// MARK: Resting Calories
// ============================================================================

struct RestingQuery: HealthQuery {
    @MainActor func fetch(
        from: Date, to: Date, limit: Int? = nil,
        store: HealthKitService
    ) async -> [RestingEnergy] {
        let samples = await store.fetchQuantitySamples(
            for: HKQuantityType(.basalEnergyBurned),
            from: from, to: to, limit: limit
        )

        let calories = samples.map { sample in
            let caloriesInKcal = sample.quantity.doubleValue(
                for: .kilocalorie()
            )
            let calories = UnitDefinition.calorie.asBase(
                caloriesInKcal, from: .kilocalories
            )
            return RestingEnergy(
                calories, date: sample.startDate,
                source: sample.sourceRevision.source.dataSource
            )
        }

        return calories
    }

    func descriptor(from: Date, to: Date) -> FetchDescriptor<RestingEnergy> {
        let predicate = #Predicate<RestingEnergy> {
            from <= $0.date && $0.date <= to
        }
        return FetchDescriptor(
            predicate: predicate,
            sortBy: [.init(\.date, order: .reverse)]
        )
    }
}
