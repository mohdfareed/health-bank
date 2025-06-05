import Foundation
import HealthKit
import SwiftUI

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
