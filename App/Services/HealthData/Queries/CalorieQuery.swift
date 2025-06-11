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
        let foods = await fetchFoods(correlations)

        let calories = await fetchCalories(
            from: from, to: to, limit: limit, store: store
        )
        let alcohols = await fetchAlcohol(
            from: from, to: to, limit: limit, store: store
        )

        // filter out any calories that are already included in the foods
        let filteredCalories = calories.filter { calorie in
            !correlations.contains(where: {
                $0.objects.contains(where: { $0.uuid == calorie.id })
            })
        }

        // filter out any alcohol that is already included in the foods
        let filteredAlcohols = alcohols.filter { alcohol in
            !correlations.contains(where: {
                $0.objects.contains(where: { $0.uuid == alcohol.id })
            })
        }

        return (foods + filteredCalories + filteredAlcohols).sorted {
            $0.date > $1.date
        }
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

        try await delete(data, store: store)
        try await store.save(correlation, of: correlationType)
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

    private func fetchAlcohol(
        from: Date, to: Date, limit: Int? = nil,
        store: HealthKitService
    ) async -> [DietaryCalorie] {
        let alcoholSamples = await store.fetchAlcoholSamples(
            from: from, to: to, limit: limit
        )

        return alcoholSamples.compactMap { sample in
            let alcoholInDrinks = sample.quantity.doubleValue(
                for: .count()
            )
            let alcohol = UnitDefinition.alcohol.asBase(
                alcoholInDrinks, from: .standardDrink
            )

            let calorie = DietaryCalorie(
                // 1 standard drink = 98 kcal
                alcohol * 98, macros: nil, alcohol: alcohol,
                id: sample.uuid,
                source: sample.sourceRevision.source.dataSource,
                date: sample.startDate
            )

            calorie.calories = calorie.calculatedCalories() ?? 0
            return calorie
        }
    }

    private func fetchCalories(
        from: Date, to: Date, limit: Int? = nil,
        store: HealthKitService
    ) async -> [DietaryCalorie] {
        let samples = await store.fetchDietarySamples(
            from: from, to: to, limit: limit
        )

        return samples.compactMap { sample in
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
    }

    private func fetchFoods(_ correlations: [HKCorrelation])
        async -> [DietaryCalorie]
    {
        return correlations.compactMap { correlation in
            let calories = correlation.objects(
                for: HKQuantityType(.dietaryEnergyConsumed)
            ).compactMap { $0 as? HKQuantitySample }.sum(as: .kilocalorie())
            let protein = correlation.objects(
                for: HKQuantityType(.dietaryProtein)
            ).compactMap { $0 as? HKQuantitySample }.sum(as: .gram())
            let fat = correlation.objects(
                for: HKQuantityType(.dietaryFatTotal)
            ).compactMap { $0 as? HKQuantitySample }.sum(as: .gram())
            let carbs = correlation.objects(
                for: HKQuantityType(.dietaryCarbohydrates)
            ).compactMap { $0 as? HKQuantitySample }.sum(as: .gram())
            let alcohol = correlation.objects(
                for: HKQuantityType(.numberOfAlcoholicBeverages)
            ).compactMap { $0 as? HKQuantitySample }.sum(as: .count())

            let caloriesInBase = UnitDefinition.calorie.asBase(
                calories ?? 0, from: .kilocalories
            )
            let proteinInBase = protein.map {
                UnitDefinition.macro.asBase($0, from: .grams)
            }
            let fatInBase = fat.map {
                UnitDefinition.macro.asBase($0, from: .grams)
            }
            let carbsInBase = carbs.map {
                UnitDefinition.macro.asBase($0, from: .grams)
            }
            let alcoholInBase = alcohol.map {
                UnitDefinition.alcohol.asBase($0, from: .standardDrink)
            }

            let calorie = DietaryCalorie(
                caloriesInBase,
                macros: .init(p: proteinInBase, f: fatInBase, c: carbsInBase),
                alcohol: alcoholInBase,
                id: correlation.uuid,
                source: correlation.sourceRevision.source.dataSource,
                date: correlation.startDate,
            )

            if calories == nil {  // calculate if not available
                calorie.calories = calorie.calculatedCalories() ?? 0
            }
            if protein == nil && fat == nil && carbs == nil {
                calorie.macros = nil  // No macros available
            }
            if alcohol == nil {
                calorie.alcohol = nil  // No alcohol available
            }
            return calorie
        }
    }
}
