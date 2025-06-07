import Foundation
import HealthKit
import SwiftUI

#if canImport(HealthKitUI)
    import HealthKitUI
#endif

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
    func checkAuthorization(for type: HKObjectType) -> HKAuthorizationStatus {
        return store.authorizationStatus(for: type)
    }

}

extension View {
    /// Add HealthKit data access request sheet to the current view.
    func healthKitAuthorizationSheet(
        isPresented: Binding<Bool>,
        service: HealthKitService
    ) -> some View {
        #if canImport(HealthKitUI)
            self.healthDataAccessRequest(
                store: service.store,
                shareTypes: healthKitDataTypes,
                readTypes: healthKitDataTypes,
                trigger: isPresented.wrappedValue
            ) { _ in isPresented.wrappedValue = false }
        #else
            self.alert(
                "Apple Health Not Available",
                isPresented: isPresented
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Apple Health is not available on this device.")
            }
        #endif
    }
}
