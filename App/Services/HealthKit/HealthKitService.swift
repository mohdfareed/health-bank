import Foundation
import HealthKit
import SwiftUI

// TODO: Add background sync:
// https://developer.apple.com/documentation/swiftdata/modelcontext/didsave

// MARK: Service
// ============================================================================

/// Service for querying HealthKit data with model-specific query methods.
public final class HealthKitService: Sendable {
    public static let AppSource = AppName

    private let logger = AppLogger.new(for: HealthKitService.self)
    private let store = HKHealthStore()

    static var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }
    var isActive: Bool {
        UserDefaults.standard.bool(for: .enableHealthKit) && Self.isAvailable
    }

    private var chronologicalSortDescriptor: NSSortDescriptor {
        NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate, ascending: false
        )
    }
}

// MARK: Authorization
// ============================================================================

extension HealthKitService {
    /// Request authorization for all required health data types.
    func requestAuthorization() {
        guard Self.isAvailable else {
            logger.warning("HealthKit not available on this device")
            return
        }

        let readTypes: Set<HKObjectType> = [
            HKQuantityType(.bodyMass),
            HKQuantityType(.dietaryEnergyConsumed),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.basalEnergyBurned),
            HKQuantityType(.dietaryProtein),
            HKQuantityType(.dietaryCarbohydrates),
            HKQuantityType(.dietaryFatTotal),
            HKWorkoutType.workoutType(),
        ]

        store.requestAuthorization(
            toShare: [], read: readTypes
        ) { [weak self] success, error in
            if let error = error {
                self?.logger.error("HealthKit authorization failed: \(error)")
            }
        }
    }

    /// Check authorization status for a specific data type.
    func checkAuthorization(for type: HKObjectType) -> HKAuthorizationStatus {
        return store.authorizationStatus(for: type)
    }
}

// MARK: Sample Query
// ============================================================================

extension HealthKitService {
    /// Execute a quantity sample query for the given date range.
    func fetchQuantitySamples(
        for type: HKQuantityType,
        from startDate: Date, to endDate: Date, limit: Int?
    ) async -> [HKQuantitySample] {
        guard isActive else {
            logger.debug("HealthKit inactive, returning empty results")
            return []
        }

        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(
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
                    let quantitySamples = samples as? [HKQuantitySample] ?? []
                    continuation.resume(returning: quantitySamples)
                }
            }
            store.execute(query)
        }
    }
}

// MARK: Correlation Query
// ============================================================================

extension HealthKitService {
    /// Execute a correlation sample query for the given date range.
    func fetchCorrelationSamples(
        for type: HKCorrelationType,
        from startDate: Date, to endDate: Date,
    ) async -> [HKCorrelation] {
        guard isActive else {
            logger.debug("HealthKit inactive, returning empty results")
            return []
        }

        return await withCheckedContinuation { continuation in
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
                    continuation.resume(returning: [])
                } else {
                    continuation.resume(returning: correlations ?? [])
                }
            }
            store.execute(query)
        }
    }
}

// MARK: Workout Query
// ============================================================================

extension HealthKitService {
    /// Execute a workout query for the given date range.
    func fetchWorkouts(
        from startDate: Date, to endDate: Date, limit: Int?
    ) async -> [HKWorkout] {
        guard isActive else {
            logger.debug("HealthKit inactive, returning empty results")
            return []
        }

        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate, end: endDate,
                options: .strictEndDate
            )

            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate, limit: limit ?? HKObjectQueryNoLimit,
                sortDescriptors: [chronologicalSortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    self.logger.error(
                        "Failed to fetch workouts: \(error)"
                    )
                    continuation.resume(returning: [])
                } else {
                    let workouts = samples as? [HKWorkout] ?? []
                    continuation.resume(returning: workouts)
                }
            }
            store.execute(query)
        }
    }
}

// MARK: Environment Integration
// ============================================================================

extension EnvironmentValues {
    /// The HealthKit service used for querying HealthKit data.
    @Entry var healthKit: HealthKitService = .init()
}

extension View {
    /// Sets the HealthKit service for the view's environment.
    func healthKit(_ service: HealthKitService) -> some View {
        environment(\.healthKit, service)
    }
}

// MARK: Extensions
// ============================================================================

extension HKSource {
    /// Returns the data source of the HealthKit source.
    var dataSource: DataSource {
        return self.bundleIdentifier == appID ? .local : .healthKit
    }
}

extension [HKQuantitySample] {
    /// Sums the quantities in the array using the specified unit.
    func sum(as unit: HKUnit) -> Double? {
        guard !isEmpty else { return nil }
        return reduce(0) {
            return $0 + $1.quantity.doubleValue(for: unit)
        }
    }
}
