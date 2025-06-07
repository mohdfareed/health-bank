import Foundation
import HealthKit
import SwiftUI

let healthKitDataTypes: Set<HKSampleType> = [
    HKQuantityType(.bodyMass),
    HKQuantityType(.dietaryEnergyConsumed),
    HKQuantityType(.activeEnergyBurned),
    HKQuantityType(.basalEnergyBurned),
    HKQuantityType(.dietaryProtein),
    HKQuantityType(.dietaryCarbohydrates),
    HKQuantityType(.dietaryFatTotal),
    HKWorkoutType.workoutType(),
]

// MARK: Authorization
// ============================================================================

/// The authorization status for HealthKit data types.
enum HealthAuthorizationStatus {
    case notReviewed
    case authorized
    case denied
    case partiallyAuthorized
}

extension HealthKitService {
    /// Request authorization for all required health data types.
    func requestAuthorization() {
        guard Self.isAvailable else {
            logger.warning("HealthKit not available on this device")
            return
        }

        store.requestAuthorization(
            toShare: healthKitDataTypes, read: healthKitDataTypes
        ) { [weak self] success, error in
            if let error = error {
                self?.logger.error("HealthKit authorization failed: \(error)")
            }
        }
    }

    /// Check authorization status for a specific data type.
    func isAuthorized(for type: HKObjectType) -> HKAuthorizationStatus {
        return store.authorizationStatus(for: type)
    }

    /// Check the overall authorization status for all health data types.
    func authorizationStatus() -> HealthAuthorizationStatus {
        if !isReviewed() {
            return .notReviewed
        } else if isAuthorized() {
            return .authorized
        } else if isDenied() {
            return .denied
        } else {
            return .partiallyAuthorized
        }
    }

    /// Check if the app has complete authorization for all types.
    private func isAuthorized() -> Bool {
        return healthKitDataTypes.allSatisfy { type in
            isAuthorized(for: type) == .sharingAuthorized
        }
    }

    /// Check if the user has reviewed the permissions for all types.
    private func isReviewed() -> Bool {
        return healthKitDataTypes.allSatisfy { type in
            isAuthorized(for: type) != .notDetermined
        }
    }

    /// Check if the user has denied permissions for all types.
    private func isDenied() -> Bool {
        return healthKitDataTypes.allSatisfy { type in
            isAuthorized(for: type) == .sharingDenied
        }
    }
}
