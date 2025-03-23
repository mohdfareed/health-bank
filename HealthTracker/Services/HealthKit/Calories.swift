import Foundation
import HealthKit
import SwiftData

func quantityParser(_ sample: HKSample, unit: HKUnit) -> Double? {
    guard let quantitySample = sample as? HKQuantitySample else { return nil }
    return quantitySample.quantity.doubleValue(for: unit)
}

let food = HKCorrelationType.init(.food)
let energy = HealthKitData(
    type: .quantityType(forIdentifier: .dietaryEnergyConsumed)!,
    sample: HKQuantitySample.self, unit: .largeCalorie()
)
let protein = HealthKitData(
    type: .quantityType(forIdentifier: .dietaryProtein)!,
    sample: HKQuantitySample.self, unit: .gram()
)
let fat = HealthKitData(
    type: .quantityType(forIdentifier: .dietaryFatTotal)!,
    sample: HKQuantitySample.self, unit: .gram()
)
let carbs = HealthKitData(
    type: .quantityType(forIdentifier: .dietaryCarbohydrates)!,
    sample: HKQuantitySample.self, unit: .gram()
)

func parseSample

extension ConsumedCalories: HealthKitModel {
    static var healthKitTypes: [HealthKitData<HKSample>] {
        [energy, protein, fat, carbs]
    }

    static func healthKitQuery(
        with descriptor: FetchDescriptor<ConsumedCalories>?,
        handler: @escaping (HKQuery, [Self], Error?) -> Void
    ) throws -> HKQuery {
        if descriptor == nil {
            let query = HKCorrelationQuery(
                type: food, predicate: nil, samplePredicates: nil,
                completion: { query, results, error in
                    guard let correlations = results else {
                        handler(query, [], error)
                        return
                    }
                    let calories: [Self] = createEntries(from: correlations)
                    handler(query, calories, error)
                }
            )
            return query
        }

        // Convert descriptor to ns predicate
        descriptor?.propertiesToFetch

        let predicate: NSPredicate? = nil

        // For demonstration: fetch all matching samples, no limit
        let query = HKSampleQuery(
            sampleType: energy,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, error in
            // The service/manager that calls this query will handle the async completion
        }
        return query
    }

    var healthKitObjects: [HKObject] {
        guard let quantityType = Self.healthKitTypes.first as? HKQuantityType else {
            return []
        }
        let quantity = HKQuantity(unit: .kilocalorie(), doubleValue: Double(self.value))
        let sample = HKQuantitySample(
            type: quantityType,
            quantity: quantity,
            start: self.date,
            end: self.date
        )
        return [sample]
    }

    convenience init(from healthKitSamples: [HKSample]) {
        var sample: HKSample
        healthKitSamples.compactMap { sample in
            guard let qSample = sample as? HKQuantitySample else { return nil }
            let value = qSample.quantity.doubleValue(for: .kilocalorie())
            // Use startDate or average if you like. We’ll just pick start:
            let date = qSample.startDate
            super.init(value: value, date: date)
        }
    }

    private static func createEntries(from correlations: [HKCorrelation]) throws -> Self {
        var calories: [Self] = []
        for correlation in correlations {
            let energy = correlation.calories

            let proteinSamples =
                (correlation.objects(for: protein) as! Set<HKQuantitySample>)
            let protein = proteinSamples.reduce(
                0, { $0 + $1.quantity.doubleValue(for: .gram()) }
            )

            let fatSamples =
                (correlation.objects(for: fat) as! Set<HKQuantitySample>)
            let fat = fatSamples.reduce(
                0, { $0 + $1.quantity.doubleValue(for: .gram()) }
            )

            let carbsSamples =
                (correlation.objects(for: carbs) as! Set<HKQuantitySample>)
            let carbs = carbsSamples.reduce(
                0, { $0 + $1.quantity.doubleValue(for: .gram()) }
            )

            let calorie = Self.init(
                UInt(energy),
                macros: try CalorieMacros(
                    protein: UInt(protein), fat: UInt(fat), carbs: UInt(carbs)
                ),
                on: correlation.startDate
            )
            calories.append(contentsOf: calories)
        }
        return calories
    }
}
