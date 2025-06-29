import Foundation
import HealthKit
import SwiftUI

// MARK: Service
// ============================================================================

/// Service for querying HealthKit data with model-specific query methods.
public class HealthKitService: @unchecked Sendable {
    internal static let shared = HealthKitService()
    internal let logger = AppLogger.new(for: HealthKitService.self)
    internal let store = HKHealthStore()

    static var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    // Sample query sorting
    internal var defaultSortDescriptor: NSSortDescriptor {
        NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate, ascending: false
        )
    }

    // User unit preferences
    @MainActor
    internal static var unitsCache: [HKQuantityType: Unit] = [:]

    // Observation management
    internal var activeObservers: [String: HKObserverQuery] = [:]
    internal let observerQueue = DispatchQueue(
        label: ObserversID, qos: .utility
    )

    private init() {
        guard Self.isAvailable else {
            logger.debug("HealthKit unavailable, skipping initialization")
            return
        }

        Task {
            await setupUnits()
            await setupBackgroundDelivery()
        }
        logger.info("HealthKit service initialized.")
    }

    /// Enable background delivery for all data types we observe
    @MainActor
    private func setupBackgroundDelivery() async {
        // Data types that our widgets monitor
        let dataTypes = HealthKitDataType.allCases.map { $0.sampleType }
        for dataType in dataTypes {
            store.enableBackgroundDelivery(
                for: dataType,
                frequency: .immediate
            ) { [weak self] success, error in
                if let error = error {
                    self?.logger.error(
                        "Failed to enable background delivery for \(dataType.identifier): \(error)")
                } else if success {
                    self?.logger.info("Enabled background delivery for \(dataType.identifier)")
                } else {
                    self?.logger.warning(
                        "Background delivery not enabled for \(dataType.identifier) (unknown reason)"
                    )
                }
            }
        }
    }
}

// MARK: Environment Integration
// ============================================================================

extension EnvironmentValues {
    /// The HealthKit service used for querying HealthKit data.
    @Entry public var healthKit: HealthKitService = .shared
}
