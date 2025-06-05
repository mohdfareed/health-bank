import Foundation
import HealthKit
import SwiftUI

// MARK: Correlation Query
// ============================================================================

extension HealthKitService {
    /// Execute a correlation sample query for the given date range.
    func fetchCorrelationSamples(
        for type: HKCorrelationType,
        from startDate: Date, to endDate: Date
    ) async -> [HKCorrelation] {
        guard isActive else {
            logger.debug("HealthKit inactive, returning empty results")
            return []
        }

        let samples: [HKCorrelation] = await withCheckedContinuation { cont in
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate, end: endDate,
                options: .strictEndDate
            )

            let query = HKCorrelationQuery(
                type: type, predicate: predicate, samplePredicates: nil
            ) { _, correlations, error in
                if let error = error {
                    self.logger.error(
                        "Failed to fetch \(type.identifier): \(error)"
                    )
                    cont.resume(returning: [])
                } else {
                    cont.resume(returning: correlations ?? [])
                }
            }
            store.execute(query)
        }

        return samples
    }
}
