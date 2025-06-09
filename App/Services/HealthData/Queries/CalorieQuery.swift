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
        let correlations = await store.fetchFoodSamples(
            from: from, to: to, limit: limit
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

            let caloriesInBase = UnitDefinition.calorie.asBase(
                totalCalories ?? 0, from: .kilocalories
            )
            let proteinInBase = totalProtein.map {
                UnitDefinition.weight.asBase($0, from: .grams)
            }
            let fatInBase = totalFat.map {
                UnitDefinition.weight.asBase($0, from: .grams)
            }
            let carbsInBase = totalCarbs.map {
                UnitDefinition.weight.asBase($0, from: .grams)
            }

            let calorie = DietaryCalorie(
                caloriesInBase,
                macros: .init(p: proteinInBase, f: fatInBase, c: carbsInBase),
                id: correlation.uuid,
                source: correlation.sourceRevision.source.dataSource,
                date: correlation.startDate,
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
                calories,
                id: sample.uuid,
                source: sample.sourceRevision.source.dataSource,
                date: sample.startDate,
            )
        }

        let alcoholSamples = await store.fetchQuantitySamples(
            for: .alcohol,
            from: from, to: to, limit: limit
        )

        let alcohols: [DietaryCalorie] = alcoholSamples.compactMap { sample in
            let alcoholInDrinks = sample.quantity.doubleValue(
                for: .count()
            )
            let alcohol = UnitDefinition.alcohol.asBase(
                alcoholInDrinks, from: .standardDrink
            )
            return DietaryCalorie(
                // 1 standard drink = 98 kcal
                alcohol * 98, macros: nil, alcohol: alcohol,
                id: sample.uuid,
                source: sample.sourceRevision.source.dataSource,
                date: sample.startDate
            )
        }

        return (calories + foods + alcohols).sorted { $0.date > $1.date }
    }

    func save(_ data: DietaryCalorie, store: HealthKitService) async throws {
        var samples = [HKSample]()

        // create the calorie sample
        let caloriesInKcal = Measurement(
            value: data.calories, unit: UnitDefinition.calorie.baseUnit
        )
        .converted(to: UnitEnergy.kilocalories).value
        let calorieQuantity = HKQuantity(
            unit: .kilocalorie(), doubleValue: caloriesInKcal
        )
        let calorieSample = HKQuantitySample(
            type: HKQuantityType(.dietaryEnergyConsumed),
            quantity: calorieQuantity,
            start: data.date, end: data.date
        )
        samples.append(calorieSample)

        // create the macro samples if available
        if let macros = data.macros {
            if let protein = macros.protein {
                let proteinQuantity = HKQuantity(
                    unit: .gram(), doubleValue: protein
                )
                let proteinSample = HKQuantitySample(
                    type: HKQuantityType(.dietaryProtein),
                    quantity: proteinQuantity,
                    start: data.date, end: data.date
                )
                samples.append(proteinSample)
            }
            if let fat = macros.fat {
                let fatQuantity = HKQuantity(
                    unit: .gram(), doubleValue: fat
                )
                let fatSample = HKQuantitySample(
                    type: HKQuantityType(.dietaryFatTotal),
                    quantity: fatQuantity,
                    start: data.date, end: data.date
                )
                samples.append(fatSample)
            }
            if let carbs = macros.carbs {
                let carbsQuantity = HKQuantity(
                    unit: .gram(), doubleValue: carbs
                )
                let carbsSample = HKQuantitySample(
                    type: HKQuantityType(.dietaryCarbohydrates),
                    quantity: carbsQuantity,
                    start: data.date, end: data.date
                )
                samples.append(carbsSample)
            }
        }

        // create the alcohol sample if available
        if let alcohol = data.alcohol {
            let alcoholInDrinks = Measurement(
                value: alcohol, unit: UnitDefinition.alcohol.baseUnit
            ).converted(to: UnitVolume.standardDrink).value
            let alcoholQuantity = HKQuantity(
                unit: .count(), doubleValue: alcoholInDrinks
            )
            let alcoholSample = HKQuantitySample(
                type: HKQuantityType(.numberOfAlcoholicBeverages),
                quantity: alcoholQuantity,
                start: data.date, end: data.date
            )
            samples.append(alcoholSample)
        }

        // create the correlation sample
        let correlationType = HKCorrelationType.correlationType(
            forIdentifier: .food
        )!
        let correlation = HKCorrelation(
            type: correlationType, start: data.date, end: data.date,
            objects: Set(samples)
        )
        try await store.save(correlation)
    }

    func delete(_ data: DietaryCalorie, store: HealthKitService) async throws {
        let predicate = HKQuery.predicateForObject(with: data.id)
        let sample = await store.fetchFoodSamples(
            from: .distantPast, to: .distantFuture, predicate: predicate
        ).first

        // Delete associated samples
        if let correlation = sample {
            for sample in correlation.objects {
                try await store.delete(sample.uuid, of: sample.sampleType)
            }
        }

        // Find alcohol samples associated with this correlation
        let alcoholSample = await store.fetchQuantitySamples(
            for: .alcohol,
            from: .distantPast, to: .distantFuture,
            predicate: HKQuery.predicateForObject(with: data.id)
        ).first

        // Delete alcohol samples if they exist
        if let alcoholSample = alcoholSample {
            try await store.delete(
                alcoholSample.uuid, of: alcoholSample.sampleType
            )
        }

        try await store.delete(
            data.id,
            of: HKObjectType.correlationType(forIdentifier: .food)!
        )
    }
}
