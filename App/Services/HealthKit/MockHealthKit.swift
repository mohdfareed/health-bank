#if DEBUG
    import Foundation
    import HealthKit
    import SwiftUI

    /// Simple mock for HealthKitService without interfaces
    final class MockHealthKitService: HealthKitService, @unchecked Sendable {
        @MainActor
        static var mockSamples: [HKSampleType: [HKSample]] = [:]
        @MainActor
        static var mockCorrelations: [HKCorrelationType: [HKCorrelation]] = [:]

        override public func fetchSamples(
            for type: HKSampleType,
            from startDate: Date, to endDate: Date, limit: Int?,
            predicate: NSPredicate? = nil
        ) async -> [HKSample] {
            guard isActive else {
                logger.debug("HealthKit inactive, returning empty results")
                return []
            }

            let samples = await Self.mockSamples[type] ?? []
            return
                samples
                .filter { $0.startDate >= startDate && $0.endDate <= endDate }
                .prefix(limit ?? samples.count).map { $0 }
        }

        override public func fetchCorrelationSamples(
            for type: HKCorrelationType,
            from startDate: Date, to endDate: Date
        ) async -> [HKCorrelation] {
            guard isActive else {
                logger.debug("HealthKit inactive, returning empty results")
                return []
            }

            let correlations = await Self.mockCorrelations[type] ?? []
            return correlations.filter {
                $0.startDate >= startDate && $0.endDate <= endDate
            }
        }
    }

    // MARK: - Sample Creation
    extension MockHealthKitService {
        @MainActor
        static func addMockSample(_ sample: HKQuantitySample, for type: HKQuantityType) {
            if mockSamples[type] == nil {
                mockSamples[type] = []
            }
            mockSamples[type]?.append(sample)
        }

        @MainActor
        static func addMockCorrelation(_ sample: HKCorrelation, for type: HKCorrelationType) {
            if mockCorrelations[type] == nil {
                mockCorrelations[type] = []
            }
            mockCorrelations[type]?.append(sample)
        }

        @MainActor
        static func clearMockData() {
            mockSamples.removeAll()
            mockCorrelations.removeAll()
        }
    }

    // MARK: - Sample Creation Helpers
    extension MockHealthKitService {
        static func createMockWeightSample(weight: Double, date: Date = Date()) -> HKQuantitySample
        {
            let quantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: weight)
            let type = HKQuantityType(.bodyMass)
            return HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
        }

        static func createMockCalorieSample(
            calories: Double, macros: CalorieMacros, date: Date = Date()
        ) -> HKCorrelation {
            let protein =
                macros.protein != nil
                ? HKQuantity(
                    unit: .gram(), doubleValue: macros.protein!
                ) : nil
            let fat =
                macros.fat != nil
                ? HKQuantity(unit: .gram(), doubleValue: macros.fat!)
                : nil
            let carbs =
                macros.carbs != nil
                ? HKQuantity(unit: .gram(), doubleValue: macros.carbs!)
                : nil

            let calorieType = HKQuantityType(.dietaryEnergyConsumed)
            let calorieQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: calories)

            var quantities: [HKQuantitySample] = [
                HKQuantitySample(
                    type: calorieType, quantity: calorieQuantity, start: date, end: date)
            ]

            if let protein = protein {
                let proteinSample = HKQuantitySample(
                    type: HKQuantityType(.dietaryProtein),
                    quantity: protein,
                    start: date, end: date
                )
                quantities.append(proteinSample)
            }

            if let fat = fat {
                let fatSample = HKQuantitySample(
                    type: HKQuantityType(.dietaryFatTotal),
                    quantity: fat,
                    start: date, end: date
                )
                quantities.append(fatSample)
            }

            if let carbs = carbs {
                let carbsSample = HKQuantitySample(
                    type: HKQuantityType(.dietaryCarbohydrates),
                    quantity: carbs,
                    start: date, end: date
                )
                quantities.append(carbsSample)
            }

            return HKCorrelation(
                type: HKCorrelationType(.food),
                start: date, end: date,
                objects: Set(quantities)
            )
        }
    }
#endif
