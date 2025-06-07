import Foundation
import HealthKit
import SwiftUI

// MARK: Sample Query
// ============================================================================

extension HealthKitService {
    public func fetchQuantitySamples(
        for type: HKQuantityType,
        from startDate: Date, to endDate: Date, limit: Int? = nil
    ) async -> [HKQuantitySample] {
        return await fetchSamples(
            for: type, from: startDate, to: endDate, limit: limit
        ) as? [HKQuantitySample] ?? []
    }

    public func fetchWorkoutSamples(
        from startDate: Date, to endDate: Date, limit: Int? = nil
    ) async -> [HKWorkout] {
        return await fetchSamples(
            for: .workoutType(), from: startDate, to: endDate, limit: limit
        ) as? [HKWorkout] ?? []
    }
}

// MARK: Activity Sample Query
// ============================================================================

extension HealthKitService {
    public func fetchActivitySamples(
        for type: HKQuantityType,
        from startDate: Date, to endDate: Date,
        workouts: [HKWorkout] = [], limit: Int? = nil
    ) async -> [HKQuantitySample] {
        let datePredicate = HKQuery.predicateForSamples(
            withStart: startDate, end: endDate,
            options: .strictEndDate
        )

        let workoutPredicate =
            NSCompoundPredicate(
                orPredicateWithSubpredicates: workouts.map {
                    HKQuery.predicateForObjects(from: $0)
                }
            )

        let notWorkoutPredicate = NSCompoundPredicate(
            notPredicateWithSubpredicate: workoutPredicate
        )
        let finalPredicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                datePredicate, notWorkoutPredicate,
            ]
        )

        return await fetchSamples(
            for: type, from: startDate, to: endDate, limit: limit,
            predicate: finalPredicate
        ) as? [HKQuantitySample] ?? []
    }
}

// MARK: Dietary Sample Query
// ============================================================================

extension HealthKitService {
    public func fetchDietarySamples(
        for type: HKQuantityType,
        from startDate: Date, to endDate: Date, limit: Int? = nil
    ) async -> [HKQuantitySample] {
        let datePredicate = HKQuery.predicateForSamples(
            withStart: startDate, end: endDate,
            options: .strictEndDate
        )

        let finalPredicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                datePredicate, HKQuery.predicateForObjectsWithNoCorrelation(),
            ]
        )

        return await fetchSamples(
            for: type, from: startDate, to: endDate, limit: limit,
            predicate: finalPredicate
        ) as? [HKQuantitySample] ?? []
    }
}
