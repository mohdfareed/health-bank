import Foundation
import HealthKit
import SwiftUI

// MARK: Sample Query
// ============================================================================

extension HealthKitService {
    internal func fetchSamples(
        for type: HKSampleType,
        from startDate: Date, to endDate: Date,
        limit: Int?, predicate: NSPredicate? = nil
    ) async -> [HKSample] {
        guard Self.isAvailable else { return [] }
        var finalPredicate = HKQuery.predicateForSamples(
            withStart: startDate, end: endDate
        )

        if let predicate = predicate {
            finalPredicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [finalPredicate, predicate]
            )
        }

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: finalPredicate,
                limit: limit ?? HKObjectQueryNoLimit,
                sortDescriptors: [defaultSortDescriptor]
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

// MARK: Correlation Query
// ============================================================================

extension HealthKitService {
    internal func fetchCorrelationSamples(
        for type: HKCorrelationType,
        from startDate: Date, to endDate: Date,
        limit: Int?, predicate: NSPredicate?
    ) async -> [HKCorrelation] {
        guard Self.isAvailable else { return [] }
        var finalPredicate = HKQuery.predicateForSamples(
            withStart: startDate, end: endDate
        )

        if let predicate = predicate {
            finalPredicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [finalPredicate, predicate]
            )
        }

        return await withCheckedContinuation { cont in
            let query = HKCorrelationQuery(
                type: type, predicate: finalPredicate, samplePredicates: nil
            ) { _, correlations, error in
                if let error = error {
                    self.logger.error(
                        "Failed to fetch \(type.identifier): \(error)"
                    )
                    cont.resume(returning: [])
                } else {
                    let results = correlations?
                        .sorted { $0.startDate > $1.startDate }
                        .prefix(limit ?? .max).map { $0 }
                    cont.resume(returning: results ?? [])
                }
            }
            store.execute(query)
        }
    }
}

// MARK: Queries
// ============================================================================

extension HealthKitService {
    public func fetchSamples(
        for type: HealthKitDataType,
        from startDate: Date = .distantPast, to endDate: Date = .distantPast,
        limit: Int? = nil, predicate: NSPredicate? = nil
    ) async -> [HKSample] {
        return await fetchSamples(
            for: type.sampleType, from: startDate, to: endDate,
            limit: limit, predicate: predicate
        )
    }

    public func fetchQuantitySamples(
        for type: HealthKitDataType,
        from startDate: Date = .distantPast, to endDate: Date = .distantPast,
        limit: Int? = nil, predicate: NSPredicate? = nil
    ) async -> [HKQuantitySample] {
        return await fetchSamples(
            for: type.quantityType, from: startDate, to: endDate,
            limit: limit, predicate: predicate
        ) as? [HKQuantitySample] ?? []
    }

    public func fetchFoodSamples(
        from startDate: Date = .distantPast, to endDate: Date = .distantPast,
        limit: Int? = nil, predicate: NSPredicate? = nil
    ) async -> [HKCorrelation] {
        return await fetchCorrelationSamples(
            for: .correlationType(forIdentifier: .food)!,
            from: startDate, to: endDate,
            limit: limit, predicate: predicate
        )
    }

    public func fetchDietarySamples(
        from startDate: Date = .distantPast, to endDate: Date = .distantPast,
        limit: Int? = nil, predicate: NSPredicate? = nil
    ) async -> [HKQuantitySample] {
        var finalPredicate = HKQuery.predicateForObjectsWithNoCorrelation()
        if let predicate = predicate {
            finalPredicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [finalPredicate, predicate]
            )
        }

        return await fetchSamples(
            for: .dietaryCalories, from: startDate, to: endDate,
            limit: limit, predicate: predicate
        ) as? [HKQuantitySample] ?? []
    }

    public func fetchAlcoholSamples(
        from startDate: Date = .distantPast, to endDate: Date = .distantPast,
        limit: Int? = nil, predicate: NSPredicate? = nil
    ) async -> [HKQuantitySample] {
        var finalPredicate = HKQuery.predicateForObjectsWithNoCorrelation()
        if let predicate = predicate {
            finalPredicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [finalPredicate, predicate]
            )
        }

        return await fetchSamples(
            for: .alcohol, from: startDate, to: endDate,
            limit: limit, predicate: predicate
        ) as? [HKQuantitySample] ?? []
    }
}
