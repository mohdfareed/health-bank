import Foundation
import HealthKit
import SwiftUI

// TODO: Add background sync

// MARK: Service
// ============================================================================

/// Service for querying HealthKit data with model-specific query methods.
public final class HealthKitService: Sendable {
    public typealias WorkoutType = HKWorkoutActivityType

    private let logger = AppLogger.new(for: HealthKitService.self)
    private let store = HKHealthStore()

    // Computed State
    static var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }
    var isActive: Bool {
        UserDefaults.standard.bool(for: .enableHealthKit) && Self.isAvailable
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
        from startDate: Date, to endDate: Date
    ) async -> [HKQuantitySample] {
        guard isActive else {
            logger.debug("HealthKit inactive, returning empty results")
            return []
        }

        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate, end: endDate,
                options: .strictStartDate
            )

            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: []
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
        from startDate: Date, to endDate: Date
    ) async -> [HKCorrelation] {
        guard isActive else {
            logger.debug("HealthKit inactive, returning empty results")
            return []
        }

        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate, end: endDate,
                options: .strictStartDate
            )

            let query = HKCorrelationQuery(
                type: type,
                predicate: predicate,
                samplePredicates: nil
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
        from startDate: Date, to endDate: Date
    ) async -> [HKWorkout] {
        guard isActive else {
            logger.debug("HealthKit inactive, returning empty results")
            return []
        }

        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate, end: endDate,
                options: .strictStartDate
            )

            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: []
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

// MARK: SwiftUI Integration
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

extension Set<HKSample> {
    func sum(as unit: HKUnit) -> Double? {
        guard !isEmpty else { return nil }
        return reduce(0) {
            guard let sample = $1 as? HKQuantitySample else {
                return $0
            }
            return $0 + sample.quantity.doubleValue(for: unit)
        }
    }
}
