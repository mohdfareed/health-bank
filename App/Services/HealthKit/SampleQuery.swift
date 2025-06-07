import Foundation
import HealthKit
import SwiftUI

// MARK: Sample Query
// ============================================================================

extension HealthKitService {
    /// Execute a sample query for the given date range.
    func fetchSamples(
        for type: HKSampleType,
        from startDate: Date, to endDate: Date, limit: Int?,
        predicate: NSPredicate? = nil
    ) async -> [HKSample] {
        guard isActive else {
            logger.debug("HealthKit inactive, returning empty results")
            return []
        }

        return await withCheckedContinuation { continuation in
            let predicate =
                predicate
                ?? HKQuery.predicateForSamples(
                    withStart: startDate, end: endDate,
                    options: .strictEndDate
                )

            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate, limit: limit ?? HKObjectQueryNoLimit,
                sortDescriptors: [chronologicalSortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    self.logger.error(
                        "Failed to fetch \(type.identifier): \(error)"
                    )
                    continuation.resume(returning: [])
                } else {
                    continuation.resume(returning: samples ?? [])
                }
            }
            store.execute(query)
        }
    }
}

extension HealthKitService {
    func fetchQuantitySamples(
        for type: HKQuantityType,
        from startDate: Date, to endDate: Date, limit: Int? = nil
    ) async -> [HKQuantitySample] {
        return await fetchSamples(
            for: type, from: startDate, to: endDate, limit: limit
        ) as? [HKQuantitySample] ?? []
    }

    func fetchWorkoutSamples(
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
    func fetchActivitySamples(
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
    func fetchDietarySamples(
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
